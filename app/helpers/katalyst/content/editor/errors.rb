# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class Errors < Base
        def build(**options)
          turbo_frame_tag dom_id(container, :errors) do
            next unless container.errors.any?

            tag.div(class: "content-errors", **options) do
              tag.h2("Errors in content") +
                tag.ul(class: "errors") do
                  container.errors.each do |error|
                    concat(tag.li(error.full_message))
                  end
                end
            end
          end
        end
      end
    end
  end
end
