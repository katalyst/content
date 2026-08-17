# frozen_string_literal: true

FactoryBot.define do
  factory :banner do
    content_item_defaults
    image { image_upload }
  end
end
