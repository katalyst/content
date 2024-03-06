# frozen_string_literal: true

module Katalyst
  module Content
    module TableHelper
      mattr_accessor(:sanitizer, default: Rails::HTML5::Sanitizer.safe_list_sanitizer.new)
      mattr_accessor(:scrubber)

      def sanitize_content_table(table)
        sanitizer.sanitize(
          table.content.body.to_html,
          tags:       content_table_allowed_tags,
          attributes: content_table_allowed_attributes,
          scrubber:,
        ).html_safe # rubocop:disable Rails/OutputSafety
      end

      private

      def content_table_allowed_tags
        Katalyst::Content::Config.table_sanitizer_allowed_tags
      end

      def content_table_allowed_attributes
        Katalyst::Content::Config.table_sanitizer_allowed_attributes
      end
    end
  end
end
