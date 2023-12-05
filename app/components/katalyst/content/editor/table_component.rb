# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class TableComponent < BaseComponent
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          dragstart->#{LIST_CONTROLLER}#dragstart
          dragover->#{LIST_CONTROLLER}#dragover
          dragenter->#{LIST_CONTROLLER}#dragenter
          dragleave->#{LIST_CONTROLLER}#dragleave
          drop->#{LIST_CONTROLLER}#drop
          dragend->#{LIST_CONTROLLER}#dragend
        ACTIONS

        renders_many :items, ->(item) do
          row = RowComponent.new(item:, container:)
          row.with_content(render(ItemComponent.new(item:, container:)))
          row
        end

        private

        def default_html_attributes
          {
            data: {
              controller:                       LIST_CONTROLLER,
              action:                           ACTIONS,
              "#{CONTAINER_CONTROLLER}_target": "container",
            },
          }
        end
      end
    end
  end
end
