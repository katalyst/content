# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class Container < Base
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          submit->#{CONTAINER_CONTROLLER}#reindex
          content:reindex->#{CONTAINER_CONTROLLER}#reindex
          content:reset->#{CONTAINER_CONTROLLER}#reset
        ACTIONS

        def build(options)
          form_with(model: container, **default_options(id: container_form_id, **options)) do |form|
            concat hidden_input
            concat(capture { yield form })
          end
        end

        private

        # Hidden input ensures that if the container is empty then the controller
        # receives an empty array.
        def hidden_input
          tag.input(type: "hidden", name: "#{attributes_scope}[id]")
        end

        def default_options(options)
          add_option(options, :data, :controller, CONTAINER_CONTROLLER)
          add_option(options, :data, :action, ACTIONS)

          options
        end
      end
    end
  end
end
