# frozen_string_literal: true

module Katalyst
  module Content
    module Version
      extend ActiveSupport::Concern

      included do # rubocop:disable Metrics/BlockLength
        include Katalyst::Content::HasTree

        # rubocop:disable Rails/ReflectionClassName
        belongs_to :parent, class_name: name.gsub(/::Version$/, ""), inverse_of: :versions
        # rubocop:enable Rails/ReflectionClassName

        attribute :nodes, Katalyst::Content::Types::NodesType.new, default: -> { [] }

        validate :ensure_items_exists
      end

      def ensure_items_exists
        parent.errors.add(:items, :missing_item) unless items.all?(&:present?)
      end

      def items
        # support building menus in memory
        # requires that items are added in order and index and depth are set
        return parent.items unless parent.persisted?

        items = parent.items.where(id: nodes.map(&:id)).index_by(&:id)
        nodes.map do |node|
          items[node.id]&.tap do |item|
            item.index = node.index
            item.depth = node.depth
          end
        end
      end

      def text
        items.filter_map(&:to_plain_text).join("\n")
      end
    end
  end
end
