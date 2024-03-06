# frozen_string_literal: true

module Katalyst
  module Content
    class Table < Item
      has_rich_text :content

      validates :content, presence: true

      default_scope { with_rich_text_content }

      def initialize_copy(source)
        super

        self.content = source.content&.body if source.content.is_a?(ActionText::RichText)
      end

      def self.permitted_params
        super + %i[content]
      end

      def valid?(context = nil)
        super(context)
      end

      def to_plain_text
        content.to_plain_text if visible?
      end

      private

      def set_defaults
        super
        self.background = Item.config.backgrounds.first
      end
    end
  end
end
