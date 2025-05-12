# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class ItemEditorComponent < BaseComponent
        include ::Turbo::FramesHelper

        alias_method :model, :item

        module Helpers
          def prefix_partial_path_with_controller_namespace
            false
          end
        end

        def before_render
          helpers.extend(Helpers)
        end

        def call
          render("form", model:, scope:, url:, id:)
        end

        def id
          dom_id(item, :form)
        end

        def scope
          :item
        end

        def title
          if item.persisted?
            "Edit #{item.model_name.human.downcase}"
          else
            "New #{item.model_name.human.downcase}"
          end
        end

        def url
          if item.persisted?
            view_context.katalyst_content.item_path(item)
          else
            view_context.katalyst_content.items_path
          end
        end
      end
    end
  end
end
