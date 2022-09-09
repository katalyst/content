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

      initializer "katalyst-content.asset" do
        config.after_initialize do |app|
          if app.config.respond_to?(:assets)
            app.config.assets.precompile += %w(katalyst-content.js)
          end
        end
      end

      initializer "katalyst-content.importmap", before: "importmap" do |app|
        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << root.join("config/importmap.rb")
          app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
        end
      end
    end
  end
end
