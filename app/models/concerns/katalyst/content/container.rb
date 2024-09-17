# frozen_string_literal: true

module Katalyst
  module Content
    module Container
      extend ActiveSupport::Concern

      included do # rubocop:disable Metrics/BlockLength
        include Katalyst::Content::GarbageCollection

        after_initialize :set_state
        after_save :set_state
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

        # Rails 7.2 dropped support for ActiveModel enums. This is a temporary workaround.
        # Intended behaviour:
        # attribute :state, :string
        # enum :state, %i[published draft unpublished].index_with(&:to_s)
        attribute :state, :string

        # Returns true if there is a published version. Note that this includes drafts.
        def published?
          %w[published draft].include?(state)
        end

        def draft?
          state == "draft"
        end

        def unpublished?
          state == "unpublished"
        end

        # Find records by their state
        scope :state, ->(values) do
          type = attribute_types[:state]

          scope = values.map do |v|
            case type.cast(v)
            when "published"
              unscoped.published
            when "draft"
              unscoped.draft
            when "unpublished"
              unscoped.unpublished
            else
              none
            end
          end.reduce(:or) || none

          merge(scope)
        end

        # Published is all records that have a published version and no unpublished saved changes.
        scope :published, -> { where(arel_table[:published_version_id].eq(arel_table[:draft_version_id])) }

        # Draft is all records who have a published version
        scope :draft, -> { where(arel_table[:published_version_id].not_eq(arel_table[:draft_version_id])) }

        # An unpublished record has a draft version but not published version.
        # This could be a new record or a record that has been unpublished.
        scope :unpublished, -> { where(published_version_id: nil) }

        scope :order_by_state, ->(dir) do
          stmt = Arel::Nodes::Case.new
          dir  = :asc unless %w[asc desc].include?(dir.to_s)

          unpublished = arel_table[:published_version_id].eq(nil)
          stmt        = stmt.when(unpublished).then(3)

          published = arel_table[:published_version_id].eq(arel_table[:draft_version_id])
          stmt      = stmt.when(published).then(2)

          # draft
          stmt = stmt.else(1)

          order(stmt.public_send(dir)).order(updated_at: dir)
        end

        def state=(_)
          raise NotImplementedError, "state cannot be set directly, use publish!, revert! etc"
        end
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

      def set_state
        state = if !published_version_id
                  :unpublished
                elsif published_version_id == draft_version_id
                  :published
                else
                  :draft
                end
        _write_attribute("state", state)
      end
    end
  end
end
