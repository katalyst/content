# frozen_string_literal: true

module Katalyst
  module Content
    class Figure < Item
      has_one_attached :image

      validates :image,
                presence:     true,
                content_type: config.image_mime_types,
                size:         { less_than: config.max_image_size.megabytes }

      default_scope { with_attached_image }

      def self.permitted_params
        super - %i[heading_style] + %i[image caption]
      end

      alias_attribute :alt, :heading

      def to_plain_text
        text = ["Image: #{alt}"]
        text << "Caption: #{caption}" if caption.present?
        text.compact.join("\n") if visible?
      end
    end
  end
end
