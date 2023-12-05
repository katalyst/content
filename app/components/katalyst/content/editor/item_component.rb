# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class ItemComponent < BaseComponent
        def edit_item_link
          if item.persisted?
            helpers.katalyst_content.edit_item_path(item)
          else
            helpers.katalyst_content.new_item_path(
              item: item.attributes.slice("type", "container_id", "container_type").compact,
            )
          end
        end

        def default_html_attributes
          {
            id:   dom_id(item),
            data: {
              controller: ITEM_CONTROLLER,
            },
          }
        end
      end
    end
  end
end
