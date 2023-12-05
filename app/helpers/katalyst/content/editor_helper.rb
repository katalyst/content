# frozen_string_literal: true

module Katalyst
  module Content
    module EditorHelper
      using Katalyst::HtmlAttributes::HasHtmlAttributes

      def content_editor_container(container:, **, &block)
        render(Editor::ContainerComponent.new(container:, **), &block)
      end

      def content_editor_list(container:, items: container.draft_items, **)
        render(Editor::TableComponent.new(container:, **)) do |list|
          items.each { |item| list.with_item(item) }
        end
      end

      # Generate a turbo stream fragment that will show structural errors to the user.
      def content_editor_errors(container:, **)
        turbo_stream.replace(dom_id(container, :errors), render(Editor::ErrorsComponent.new(container:, **)))
      end

      def content_editor_status_bar(container:, **)
        render(Editor::StatusBarComponent.new(container:, **))
      end

      def content_editor_rich_text_attributes(**)
        {
          data: {
            direct_upload_url: direct_uploads_url,
            controller:        "content--editor--trix",
            action:            "trix-initialize->content--editor--trix#trixInitialize",
          },
        }.merge_html(**)
      end

      # When rendering item forms do not include the controller namespace prefix (katalyst/content)
      def prefix_partial_path_with_controller_namespace
        false
      end
    end
  end
end
