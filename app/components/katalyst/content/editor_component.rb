# frozen_string_literal: true

module Katalyst
  module Content
    class EditorComponent < Editor::BaseComponent
      include ::Turbo::FramesHelper

      renders_one :new_items, -> do
        Katalyst::Content::Editor::NewItemsComponent.new(container:)
      end

      attr_reader :url, :scope

      def initialize(container:, url: [:admin, container], scope: :container, **)
        super(container:, **)

        @url   = url
        @scope = scope
      end

      def status_bar
        Editor::StatusBarComponent.new(container:)
      end

      def item_editor(item:)
        Editor::ItemEditorComponent.new(container:, item:)
      end

      def item(item:)
        Editor::ItemComponent.new(container:, item:)
      end

      def errors
        Katalyst::Content.config.errors_component.constantize.new(container:)
      end

      def default_html_attributes
        {
          id:    container_form_id,
          class: "content--editor",
          data:  {
            controller: "content--editor--container",
            action:     %w[
              submit->content--editor--container#reindex
              content:drop->content--editor--container#drop
              content:reindex->content--editor--container#reindex
              turbo:render@document->content--editor--container#connect
              content:reset->content--editor--container#reset
            ],
          },
        }
      end
    end
  end
end
