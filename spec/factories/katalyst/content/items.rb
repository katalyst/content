# frozen_string_literal: true

FactoryBot.define do
  factory :katalyst_content_item, class: "Katalyst::Content::Item" do
    heading { Faker::Lorem.word }
    show_heading { true }
    background { Katalyst::Content.config.backgrounds.sample }
  end
end
