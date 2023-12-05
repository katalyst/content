# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class ContainerComponent < BaseComponent
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          submit->#{CONTAINER_CONTROLLER}#reindex
          content:drop->#{CONTAINER_CONTROLLER}#drop
          content:reindex->#{CONTAINER_CONTROLLER}#reindex
          content:reset->#{CONTAINER_CONTROLLER}#reset
        ACTIONS

        attr_reader :url, :scope

        def initialize(url:, scope:, **)
          super(**)

          @url = url
          @scope = scope
        end

        def default_html_attributes
          {
            id:   container_form_id,
            data: {
              controller: CONTAINER_CONTROLLER,
              action:     ACTIONS,
            },
          }
        end
      end
    end
  end
end
