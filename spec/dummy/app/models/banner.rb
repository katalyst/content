# frozen_string_literal: true

# Content item with optional attachments. Not distributed with the gem;
# exists to test copy-on-write behaviour when a user removes an optional
# attachment by submitting "" (as govuk_attachment_field does when no file
# is selected).
class Banner < Katalyst::Content::Item
  has_one_attached :image
  has_many_attached :slides

  has_rich_text :subtitle

  has_one :banner_detail, as: :detailable, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :banner_detail, update_only: true
  duplicates_association :banner_detail

  has_many :banner_notes, as: :notable, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :banner_notes, allow_destroy: true
  duplicates_association :banner_notes

  validates :image,
            content_type: config.image_mime_types,
            size:         { less_than: config.max_image_size.megabytes }

  default_scope { with_attached_image }

  def self.permitted_params
    super + %i[image]
  end
end
