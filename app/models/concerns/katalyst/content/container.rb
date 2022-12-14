# frozen_string_literal: true

module Katalyst
  module Content
    module Container
      extend ActiveSupport::Concern

      included do # rubocop:disable Metrics/BlockLength
        include Katalyst::Content::GarbageCollection

        before_destroy :unset_versions

        belongs_to :draft_version,
                   autosave:   true,
                   class_name: "#{name}::Version",
                   inverse_of: :parent,
                   optional:   true
        belongs_to :published_version,
                   class_name: "#{name}::Version",
                   inverse_of: :parent,
                   optional:   true

        delegate :nodes, :items, :tree, :text, to: :published_version, prefix: :published, allow_nil: true
        delegate :nodes, :items, :tree, :text, to: :draft_version, prefix: :draft, allow_nil: true

        has_many :versions,
                 class_name:  "#{name}::Version",
                 dependent:   :delete_all,
                 foreign_key: :parent_id,
                 inverse_of:  :parent,
                 validate:    true do
          def active
            parent = proxy_association.owner
            where(id: [parent.published_version_id, parent.draft_version_id].uniq.compact)
          end

          def inactive
            parent = proxy_association.owner
            where.not(id: [parent.published_version_id, parent.draft_version_id].uniq.compact)
          end
        end

        has_many :items,
                 as:         :container,
                 autosave:   true,
                 class_name: "Katalyst::Content::Item",
                 dependent:  :destroy,
                 validate:   true

        scope :order_by_state, ->(dir) do
          dir            = :asc unless %w[asc desc].include?(dir.to_s)
          unpublished    = arel_table[:published_version_id].eq(nil)
          draft          = arel_table[:published_version_id].not_eq(arel_table[:draft_version_id])
          case_statement = Arel::Nodes::Case.new
                             .when(unpublished).then(3)
                             .when(draft).then(2)
                             .else(1)
          order(case_statement.public_send(dir)).order(updated_at: dir)
        end

        scope :published, -> { where.not(published_version_id: nil) }
      end

      # A resource is in draft mode if it has an unpublished draft or it has no published version.
      # @return the current state of the resource, either `published` or `draft`
      def state
        if !published_version_id
          :unpublished
        elsif published_version_id != draft_version_id
          :draft
        else
          :published
        end
      end

      def published?
        published_version_id.present?
      end

      # Promotes the draft version to become the published version
      def publish!
        update!(published_version: draft_version)
        self
      end

      # Reverts the draft version to the current published version
      def revert!
        update!(draft_version: published_version)
        self
      end

      # Sets the currently published version to nil
      def unpublish!
        update!(published_version_id: nil)
        self
      end

      # Required for testing items validation
      def items_attributes
        draft_version&.nodes&.as_json
      end

      # Updates the current draft version with new structure. Attributes should be structural information about the
      # items, e.g. `{index => {id:, depth:}` or `[{id:, depth:}]`.
      #
      # This method conforms to the behaviour of `accepts_nested_attributes_for` so that it can be used with rails form
      # helpers.
      def items_attributes=(attributes)
        next_version.nodes = attributes
      end

      private

      def unset_versions
        self.draft_version_id = nil
        self.published_version_id = nil
        save!(validate: false)
      end

      # Returns an unsaved copy of draft version for accumulating changes.
      def next_version
        if draft_version.nil?
          build_draft_version
        elsif draft_version.persisted?
          self.draft_version = draft_version.dup
        else
          draft_version
        end
      end
    end
  end
end
