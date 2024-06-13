# frozen_string_literal: true

module Katalyst
  module Content
    class Table < Item
      has_rich_text :content

      attribute :heading_rows, :integer
      attribute :heading_columns, :integer

      validates :content, presence: true

      default_scope { with_rich_text_content }

      after_initialize :set_defaults

      def initialize_copy(source)
        super

        content.body = source.content&.body if source.content.is_a?(ActionText::RichText)
      end

      def self.permitted_params
        super + %i[content heading_rows heading_columns]
      end

      def valid?(context = nil)
        super
      end

      def to_plain_text
        content.to_plain_text if visible?
      end

      def content=(value)
        Tables::Importer.call(self, value)

        set_defaults

        content
      end

      private

      def set_defaults
        super

        if content.present? && (fragment = content.body.fragment)
          self.heading_rows    ||= fragment.find_all("thead > tr").count
          self.heading_columns ||= fragment.find_all("tbody > tr:first-child > th").count
        end
      end
    end
  end
end
