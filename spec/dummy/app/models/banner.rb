# frozen_string_literal: true

# Content item with optional attachments. Not distributed with the gem;
# exists to test copy-on-write behaviour when a user removes an optional
# attachment by submitting "" (as govuk_attachment_field does when no file
# is selected).
class Banner < Katalyst::Content::Item
  has_one_attached :image
  has_many_attached :slides

  has_rich_text :subtitle

  validates :image,
            content_type: config.image_mime_types,
            size:         { less_than: config.max_image_size.megabytes }

  default_scope { with_attached_image }

  def self.permitted_params
    super + %i[image]
  end
end
