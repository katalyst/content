# frozen_string_literal: true

module Katalyst
  module Content
    module FrontendHelper
      def render_content(version)
        without_partial_path_prefix do
          render partial: version.tree.select(&:visible?)
        end
      end

      def render_content_items(items)
        items = items.select(&:visible?)
        without_partial_path_prefix do
          render partial: items if items.any?
        end
      end

      def content_item_tag(item, **options, &block)
        FrontendBuilder.new(self, item).render(**options, &block)
      end

      private

      def without_partial_path_prefix
        current = prefix_partial_path_with_controller_namespace

        self.prefix_partial_path_with_controller_namespace = false
        yield
      ensure
        self.prefix_partial_path_with_controller_namespace = current
      end
    end

    class FrontendBuilder
      attr_accessor :template, :item

      delegate_missing_to :@template

      def initialize(template, item)
        self.template = template
        self.item     = item
      end

      def render(**options, &block)
        content_tag tag, **default_options(**options) do
          content_tag :div, &block
        end
      end

      private

      def default_options(**options)
        {
          id:    item.heading&.parameterize,
          class: ["content-item", item.model_name.param_key, item.background, options[:class]],
          data:  { content_index: item.index, content_depth: item.depth, **options.fetch(:data, {}) },
          **options.except(:class, :data, :root),
        }
      end

      def tag
        case item
        when Figure
          :figure
        when Section
          :section
        else
          :div
        end
      end
    end
  end
end
