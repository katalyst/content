# frozen_string_literal: true

require "active_storage_validations"

module Katalyst
  module Content
    class Figure < Item
      has_one_attached :image

      validates :image,
                presence:     true,
                content_type: config.image_mime_types,
                size:         { less_than: config.max_image_size.megabytes }

      default_scope { with_attached_image }

      def initialize_dup(source)
        super

        # if image has changed, duplicate the change, otherwise attach the existing blob
        if source.attachment_changes["image"]
          self.image = source.attachment_changes["image"].attachable
        elsif source.image.attached? && !source.image.marked_for_destruction?
          image.attach(source.image.blob)
        end
      end

      def self.permitted_params
        super - %i[show_heading] + %i[image caption]
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
