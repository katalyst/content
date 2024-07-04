# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    transient do
      state { "published" }
    end

    title { Faker::Beer.unique.name }
    slug { title.parameterize }

    trait :unpublished do
      state { "unpublished" }
    end

    trait :published do
      state { "published" }
    end

    trait :draft do
      state { "draft" }
    end

    after(:build) do |page, _context|
      page.items.each { |item| item.container = page }
    end

    after(:create) do |page, context|
      page.items_attributes = page.items.map.with_index do |item, index|
        { id: item.id, index:, depth: item.depth }
      end

      case context.state
      when "unpublished"
        page.save!
      when "published"
        page.publish!
      when "draft"
        page.publish!
        page.items_attributes = page.published_version.nodes.as_json
        page.save!
      end
    end
  end
end
