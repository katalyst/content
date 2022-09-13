# frozen_string_literal: true

require "active_support/configurable"

module Katalyst
  module Content
    class Config
      include ActiveSupport::Configurable
      config_accessor(:backgrounds) { %w[light dark] }
    end
  end
end
