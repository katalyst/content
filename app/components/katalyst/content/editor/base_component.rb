# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class BaseComponent < ViewComponent::Base
        include Katalyst::HtmlAttributes

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
