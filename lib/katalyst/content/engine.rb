# frozen_string_literal: true

require "rails"

module Katalyst
  module Content
    class Engine < ::Rails::Engine
      isolate_namespace Katalyst::Content

      initializer "katalyst-content.factories", after: "factory_bot.set_factory_paths" do
        FactoryBot.definition_file_paths << Engine.root.join("spec/factories") if defined?(FactoryBot)
      end

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot
        g.factory_bot dir: "spec/factories"
      end
    end
  end
end
