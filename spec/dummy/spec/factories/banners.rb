# frozen_string_literal: true

FactoryBot.define do
  factory :banner do
    content_item_defaults
    image { image_upload }
    subtitle { Faker::Hacker.say_something_smart }
  end
end
