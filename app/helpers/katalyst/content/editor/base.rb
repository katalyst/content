# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class Base
        CONTAINER_CONTROLLER  = "content--editor--container"
        LIST_CONTROLLER       = "content--editor--list"
        ITEM_CONTROLLER       = "content--editor--item"
        STATUS_BAR_CONTROLLER = "content--editor--status-bar"
        NEW_ITEM_CONTROLLER   = "content--editor--new-item"

        TURBO_FRAME = "content--editor--item-frame"

        attr_accessor :template, :container

        delegate :config, to: ::Katalyst::Content
        delegate_missing_to :template

        def initialize(template, container)
          self.template  = template
          self.container = container
        end

        def container_form_id
          dom_id(container, :items)
        end

        def attributes_scope
          "#{container.model_name.param_key}[items_attributes][]"
        end

        private

        def add_option(options, key, *path)
          if path.length > 1
            add_option(options[key] ||= {}, *path)
          else
            options[key] = [options[key], *path].compact.join(" ")
          end
        end
      end
    end
  end
end
