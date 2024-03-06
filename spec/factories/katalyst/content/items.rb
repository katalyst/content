# frozen_string_literal: true

FactoryBot.define do
  trait :content_item_defaults do
    heading { Faker::Lorem.word }
    heading_style { "default" }
    background { Katalyst::Content.config.backgrounds.sample }
    depth { 0 }
  end

  factory :katalyst_content_item, class: "Katalyst::Content::Item" do
    content_item_defaults
  end

  factory :katalyst_content_content, class: "Katalyst::Content::Content" do
    content_item_defaults
    content { Faker::Hacker.say_something_smart }
  end

  factory :katalyst_content_figure, class: "Katalyst::Content::Figure" do
    content_item_defaults
    image { image_upload }
    alt { Faker::Lorem.sentence }
    caption { Faker::Hacker.say_something_smart }
  end

  factory :katalyst_content_section, class: "Katalyst::Content::Section" do
    content_item_defaults
  end

  factory :katalyst_content_group, class: "Katalyst::Content::Group" do
    content_item_defaults
  end

  factory :katalyst_content_aside, class: "Katalyst::Content::Aside" do
    content_item_defaults
  end

  factory :katalyst_content_column, class: "Katalyst::Content::Column" do
    content_item_defaults
  end

  factory :katalyst_content_table, class: "Katalyst::Content::Table" do
    content_item_defaults
    content { <<~HTML }
      <table>
        <caption>Contacts</caption>
        <thead>
        <tr>
          <th>Name</th>
          <th>Email</th>
        </tr>
        </thead>
        <tbody>
        <tr>
          <td>John Doe</td>
          <td>john.doe@example.com</td>
        </tr>
        </tbody>
      </table>
    HTML
  end
end
