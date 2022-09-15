# frozen_string_literal: true

module Katalyst
  module Content
    class Content < Item
      has_rich_text :content

      validates :content, presence: true

      def initialize_copy(source)
        super

        self.content = source.content&.body if source.content.is_a?(ActionText::RichText)
      end

      def self.permitted_params
        super + %i[content]
      end

      def to_plain_text
        [super, content.to_plain_text].compact.join("\n")
      end
    end
  end
end
