# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class NewItemComponent < BaseComponent
        include ::Turbo::StreamsHelper

        with_collection_parameter :item

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

        alias icon_name item_type

        private

        def default_html_attributes
          {
            class: "button",
            role:  "listitem",
            data:  {
              ghost_button: "",
              action:       "content--editor--new-items#add",
            },
          }
        end
      end
    end
  end
end
