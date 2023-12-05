# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class ErrorsComponent < BaseComponent
        include Katalyst::Tables::TurboReplaceable

        def id
          dom_id(container, :errors)
        end
      end
    end
  end
end
