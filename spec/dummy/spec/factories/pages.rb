# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    transient do
      _publish { true }
    end

    title { Faker::Beer.unique.name }
    slug { title.parameterize }

    trait :unpublished do
      _publish { false }
    end

    after(:build) do |page, _context|
      page.items.each { |item| item.container = page }
    end

    after(:create) do |page, context|
      page.items_attributes = page.items.map.with_index do |item, index|
        { id: item.id, index: index, depth: item.depth }
      end

      if context._publish
        page.publish!
      else
        page.save!
      end
    end
  end
end
