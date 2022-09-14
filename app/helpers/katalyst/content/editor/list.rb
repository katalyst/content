# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class List < Base
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          dragstart->#{LIST_CONTROLLER}#dragstart
          dragover->#{LIST_CONTROLLER}#dragover
          dragenter->#{LIST_CONTROLLER}#dragenter
          dragleave->#{LIST_CONTROLLER}#dragleave
          drop->#{LIST_CONTROLLER}#drop
          dragend->#{LIST_CONTROLLER}#dragend
        ACTIONS

        def build(options, &_block)
          tag.ol **default_options(id: container_form_id, **options) do
            yield self
          end
        end

        def items(*items)
          render partial:    "katalyst/content/editor/item",
                 layout:     "katalyst/content/editor/list_item",
                 collection: items,
                 as:         :item
        end

        private

        def default_options(options)
          add_option(options, :data, :controller, LIST_CONTROLLER)
          add_option(options, :data, :action, ACTIONS)
          add_option(options, :data, :"#{CONTAINER_CONTROLLER}_target", "container")

          options
        end
      end
    end
  end
end
