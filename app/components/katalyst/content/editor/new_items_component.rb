# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class NewItemsComponent < BaseComponent
        renders_many :items, Editor::NewItemComponent

        attr_reader :item_types

        def initialize(container:, **)
          super

          @item_types = Katalyst::Content.config.items.map do |item_class|
            item_class.is_a?(String) ? item_class.safe_constantize : item_class
          end.index_by do |item_class|
            item_class.new.item_type.to_sym
          end
        end

        def items
          item_types.values.map do |item_class|
            item_class.new(container:)
          end
        end

        def item(type)
          item = item_class_for(type).new(container:)
          render Editor::NewItemComponent.new(item:)
        end

        private

        def item_class_for(type)
          item_types.fetch(type) do
            raise ArgumentError, "Unknown type: #{type.inspect}, supported types: #{item_types.keys.join(', ')}"
          end
        end
      end
    end
  end
end
