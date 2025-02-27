# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class BaseComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes

        CONTAINER_CONTROLLER  = "content--editor--container"
        LIST_CONTROLLER       = "content--editor--list"
        ITEM_CONTROLLER       = "content--editor--item"
        STATUS_BAR_CONTROLLER = "content--editor--status-bar"
        NEW_ITEMS_CONTROLLER  = "content--editor--new-items"

        attr_accessor :container, :item

        delegate :config, to: ::Katalyst::Content

        def initialize(container:, item: nil, **)
          super(**)

          @container = container
          @item = item
        end

        def call; end

        def container_form_id
          dom_id(container, :items)
        end

        def attributes_scope
          "#{container.model_name.param_key}[items_attributes][]"
        end

        def inspect
          if item.present?
            "<#{self.class.name} container: #{container.inspect}, item: #{item.inspect}>"
          else
            "<#{self.class.name} container: #{container.inspect}>"
          end
        end
      end
    end
  end
end
