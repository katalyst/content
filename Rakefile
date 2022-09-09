# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)

load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"

# prepend test:prepare to run generators, builds css, and db:prepare to run migrations
RSpec::Core::RakeTask.new(spec: %w[app:test:prepare app:db:prepare])

RuboCop::RakeTask.new

desc "Run all linters"
task default: %i[spec rubocop]
