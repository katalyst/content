# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class TableComponent < BaseComponent
        renders_many :items, ->(item) do
          row = RowComponent.new(item:, container:)
          row.with_content(render(ItemComponent.new(item:, container:)))
          row
        end

        private

        def default_html_attributes
          {
            class: "katalyst--content--editor",
            data:  {
              controller:                        "content--editor--list",
              action:                            %w[
                dragstart->content--editor--list#dragstart
                dragover->content--editor--list#dragover
                drop->content--editor--list#drop
                dragend->content--editor--list#dragend
                keyup.esc@document->content--editor--list#dragend
              ],
              content__editor__container_target: "container",
            },
            role:  "list",
          }
        end
      end
    end
  end
end
