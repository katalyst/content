# frozen_string_literal: true

module Katalyst
  module Content
    module EditorHelper
      def content_editor_new_items(container:)
        Katalyst::Content.config.items.map do |item_class|
          item_class = item_class.is_a?(String) ? item_class.safe_constantize : item_class
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
    end
  end
end
