# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "dartsass-rails"
gem "importmap-rails"
gem "rails"
gem "rake"
gem "rubocop-katalyst", require: false
gem "sprockets-rails"
gem "sqlite3"

group :development, :test do
  gem "factory_bot_rails"
  gem "puma"
  gem "rspec-rails"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rake"
  gem "rubocop-rspec"
end

group :test do
  # Considering as a candidate vs cuprite, as it has partial html5 drag/drop
  # No commits since 2021, possibly abandoned
  gem "apparition", git: "https://github.com/twalpole/apparition.git"
  gem "capybara"
  gem "faker"
  # Brings back assigns to your controller tests
  gem "rails-controller-testing"
  gem "shoulda-matchers"
end
