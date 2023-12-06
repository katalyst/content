# frozen_string_literal: true

module Katalyst
  module Content
    class EditorComponent < Editor::BaseComponent
      ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
        submit->#{CONTAINER_CONTROLLER}#reindex
        content:drop->#{CONTAINER_CONTROLLER}#drop
        content:reindex->#{CONTAINER_CONTROLLER}#reindex
        content:reset->#{CONTAINER_CONTROLLER}#reset
      ACTIONS

      attr_reader :url, :scope

      def initialize(container:, url: [:admin, container], scope: :container, **)
        super(container:, **)

        @url   = url
        @scope = scope
      end

      def status_bar
        Editor::StatusBarComponent.new(container:)
      end

      def new_items
        Editor::NewItemsComponent.new(container:)
      end

      def item(item:)
        Editor::ItemComponent.new(container:, item:)
      end

      def errors
        Katalyst::Content.config.errors_component.constantize.new(container:)
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
