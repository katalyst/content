# frozen_string_literal: true

FactoryBot.define do
  factory :page do
    title { Faker::Beer.unique.name }
    slug { title.parameterize }
  end
end
