# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    title { Faker::Beer.unique.name }
    slug { title.parameterize }

    after(:build) do |page, _context|
      page.items.each { |item| item.container = page }
    end

    after(:create) do |page, _context|
      page.items_attributes = page.items.map.with_index { |item, index| { id: item.id, index: index, depth: 0 } }
      page.publish!
    end
  end
end
