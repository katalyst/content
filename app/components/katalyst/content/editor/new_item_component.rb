# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class NewItemComponent < BaseComponent
        include ::Turbo::StreamsHelper

        with_collection_parameter :item

        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          dragstart->#{NEW_ITEM_CONTROLLER}#dragstart
        ACTIONS

        def initialize(item:, container: item.container)
          super
        end

        def item_component(**)
          ItemComponent.new(item:, container:, **)
        end

        def row_component(**)
          RowComponent.new(item:, container:, **)
        end

        def label
          t("katalyst.content.editor.new_item.#{item_type}", default: item.model_name.human)
        end

        def item_type
          item.model_name.param_key
        end

        private

        def default_html_attributes
          {
            draggable: "true",
            role:      "listitem",
            data:      {
              item_type:,
              controller: NEW_ITEM_CONTROLLER,
              action:     ACTIONS,
            },
          }
        end
      end
    end
  end
end
