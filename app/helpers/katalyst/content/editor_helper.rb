# frozen_string_literal: true

module Katalyst
  module Content
    module EditorHelper
      def content_editor_new_items(container:)
        Katalyst::Content.config.items.map do |item_class|
          item_class = item_class.safe_constantize if item_class.is_a?(String)
          item_class.new(container: container)
        end
      end

      def content_editor_container(container:, **options, &block)
        Editor::Container.new(self, container).build(options, &block)
      end

      def content_editor_list(container:, items: container.draft_items, **options)
        Editor::List.new(self, container).build(options) do |list|
          list.items(*items) if items.present?
        end
      end

      # Generate items without their list wrapper, similar to form_with/fields
      def content_editor_items(item:, container: item.container)
        Editor::List.new(self, container).items(item)
      end

      # Generate a turbo stream fragment that will show structural errors to the user.
      def content_editor_errors(container:, **options)
        turbo_stream.replace(dom_id(container, :errors),
                             Editor::Errors.new(self, container).build(**options))
      end

      # Gene
      def content_editor_new_item(item:, container: item.container, **options, &block)
        Editor::NewItem.new(self, container).build(item, **options, &block)
      end

      def content_editor_item(item:, container: item.container, **options, &block)
        Editor::Item.new(self, container).build(item, **options, &block)
      end

      def content_editor_status_bar(container:, **options)
        Editor::StatusBar.new(self, container).build(**options)
      end

      def content_editor_rich_text_options(options = {})
        defaults = {
          data: {
            direct_upload_url: direct_uploads_url,
            controller:        "content--editor--trix",
            action:            <<~ACTIONS,
              trix-initialize->content--editor--trix#trixInitialize
              trix-paste->content--editor--trix#trixPaste
            ACTIONS
          },
        }
        defaults.deep_merge(options)
      end

      def content_editor_image_field(...)
        Editor::ImageField.new(self, item.container).build(...)
      end

      # When rendering item forms do not include the controller namespace prefix (katalyst/content)
      def prefix_partial_path_with_controller_namespace
        false
      end
    end
  end
end
