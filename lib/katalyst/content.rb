# frozen_string_literal: true

require "active_support"
require "katalyst/html_attributes"
require "katalyst/kpop"

require "katalyst/content/config"
require "katalyst/content/engine"

module Katalyst
  module Content
    extend self

    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end
  end
end
