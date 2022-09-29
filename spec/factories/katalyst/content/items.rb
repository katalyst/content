# frozen_string_literal: true

FactoryBot.define do
  factory :katalyst_content_item, class: "Katalyst::Content::Item" do
    heading { Faker::Lorem.word }
    show_heading { true }
    background { Katalyst::Content.config.backgrounds.sample }
    depth { 0 } # Used for nesting items in system specs
  end

  factory :katalyst_content_content, class: "Katalyst::Content::Content" do
    heading { Faker::Lorem.word }
    show_heading { true }
    background { Katalyst::Content.config.backgrounds.sample }
    depth { 0 } # Used for nesting items in system specs

    content { Faker::Hacker.say_something_smart }
  end

  factory :katalyst_content_section, class: "Katalyst::Content::Section" do
    heading { Faker::Lorem.word }
    show_heading { true }
    background { Katalyst::Content.config.backgrounds.sample }
    depth { 0 } # Used for nesting items in system specs
  end
end
