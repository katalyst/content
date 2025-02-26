# frozen_string_literal: true

require "active_storage_validations"
require "active_support"

module Katalyst
  module Content
    extend ActiveSupport::Autoload
    extend self

    autoload :Config

    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end
end

require "katalyst/content/engine"
