# frozen_string_literal: true

module Katalyst
  module Content
    # Copies declared associations when a record is duplicated, e.g. for
    # copy-on-write. Intended for owned detail records that extend an STI
    # item with attributes beyond the shared table:
    #
    #   has_one :detail, as: :detailable, autosave: true, dependent: :destroy
    #   accepts_nested_attributes_for :detail, update_only: true
    #   duplicates_association :detail
    #
    # Unsaved changes on the source's association are carried over to the
    # duplicate. Records marked for destruction are dropped.
    module DuplicatesAssociations
      extend ActiveSupport::Concern

      included do
        class_attribute :duplicated_associations, instance_writer: false, default: []
      end

      class_methods do
        def duplicates_association(*names)
          self.duplicated_associations += names.map(&:to_sym)
        end
      end

      def initialize_dup(source)
        super

        duplicated_associations.each do |name|
          macro = self.class.reflect_on_association(name).macro
          DUPLICATORS.fetch(macro).new(name).apply(source, self)
        end
      end

      # Duplicates a has_one association from source to target.
      # Public API: can be used directly for models that want to duplicate a
      # specific association without including the concern, e.g.
      #   DuplicatesAssociations::DupOne.new(:detail).apply(source, self)
      class DupOne
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def apply(source, target)
          record = source.public_send(name)

          target.public_send("#{name}=", record.dup) unless record.nil? || record.marked_for_destruction?
        end
      end

      # Duplicates a has_many association from source to target.
      # Public API: can be used directly for models that want to duplicate a
      # specific association without including the concern, e.g.
      #   DuplicatesAssociations::DupMany.new(:notes).apply(source, self)
      class DupMany
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def apply(source, target)
          records = source.public_send(name).reject(&:marked_for_destruction?).map(&:dup)

          target.public_send("#{name}=", records) if records.any?
        end
      end

      DUPLICATORS = {
        has_one:  DupOne,
        has_many: DupMany,
      }.freeze
    end
  end
end
