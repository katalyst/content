# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class ItemEditorComponent < BaseComponent
        include ::Turbo::FramesHelper

        module Helpers
          def prefix_partial_path_with_controller_namespace
            false
          end
        end

        def call
          tag.div(**html_attributes) do
            helpers.extend(Helpers)
            helpers.render(item, path:)
          end
        end

        def id
          "item-editor-#{item.id}"
        end

        def title
          if item.persisted?
            "Edit #{item.model_name.human.downcase}"
          else
            "New #{item.model_name.human.downcase}"
          end
        end

        def path
          if item.persisted?
            view_context.katalyst_content.item_path(item)
          else
            view_context.katalyst_content.items_path
          end
        end

        def default_html_attributes
          {
            id:,
            class: "content--item-editor",
          }
        end
      end
    end
  end
end
