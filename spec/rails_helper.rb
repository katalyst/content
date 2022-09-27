# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "spec_helper"
require File.expand_path("dummy/config/environment", __dir__)
require "rspec/rails"
require "active_storage_validations/matchers"

Dir[Katalyst::Content::Engine.root.join("spec", "support", "**", "*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include ActiveSupport::Testing::TimeHelpers
  config.include ActiveStorageValidations::Matchers
  config.include FileHelper, type: :request
end
