# frozen_string_literal: true

module Katalyst
  module Content
    module FrontendHelper
      include TableHelper

      using Katalyst::HtmlAttributes::HasHtmlAttributes

      # Render all items from a content version as HTML
      # @param version [Katalyst::Content::Version] The content version to render
      # @return [ActiveSupport::SafeBuffer,String,nil] Content as HTML
      # Example usage:
      #   <%= render_content(version) %>
      def render_content(version)
        capture do
          cache version do
            without_partial_path_prefix do
              concat(render_content_items(*version.tree.select(&:visible?)))
            end
          end
        end
      end

      def render_content_items(*items, tag: :div, theme: nil, **)
        items = items.flatten.select(&:visible?)

        grouped_items = items.slice_when { |first, second| first.theme != second.theme }

        grouped_items.each do |siblings|
          content_theme = (siblings.first.theme if siblings.first.theme != theme)
          concat(content_items_tag(tag, content_theme:, **) do
            without_partial_path_prefix do
              concat(render(partial: siblings))
            end
          end)
        end
      end

      def content_item_tag(item, ...)
        FrontendBuilder.new(self, item).render(...)
      end

      def content_items_tag(tag, content_theme:, **attributes, &)
        html_attributes = {
          class: "content-items",
          data:  {
            content_theme:,
          },
        }.merge_html(attributes)
        content_tag(tag, **html_attributes, &)
      end

      def without_partial_path_prefix
        current = prefix_partial_path_with_controller_namespace

        self.prefix_partial_path_with_controller_namespace = false
        yield
      ensure
        self.prefix_partial_path_with_controller_namespace = current
      end
    end

    class FrontendBuilder
      include Katalyst::HtmlAttributes

      attr_accessor :template, :item

      delegate_missing_to :@template

      def initialize(template, item)
        self.template = template
        self.item     = item
      end

      def render(tag: :div, **, &)
        update_html_attributes(**)

        content_tag(tag, **html_attributes, &)
      end

      private

      def default_html_attributes
        {
          id:    item.dom_id,
          class: ["content-item",
                  ("wrapper" if item.depth.zero?)],
          data:  {
            content_index:     item.index,
            content_depth:     item.depth,
            content_item_type: item.item_type,
          },
        }
      end
    end
  end
end
