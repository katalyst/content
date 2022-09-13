# frozen_string_literal: true

FactoryBot.define do
  factory :katalyst_content_item, class: "Katalyst::Content::Item" do
    heading { Faker::Lorem.word }
    show_heading { true }
    background { Katalyst::Content.config.backgrounds.sample }
  end

  factory :katalyst_content_content, class: "Katalyst::Content::Content" do
    heading { Faker::Lorem.word }
    show_heading { true }
    background { Katalyst::Content.config.backgrounds.sample }
    content { Faker::Hacker.say_something_smart }
  end
end
