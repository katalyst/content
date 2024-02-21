# frozen_string_literal: true

require "active_support/configurable"

module Katalyst
  module Content
    class Config
      include ActiveSupport::Configurable

      config_accessor(:backgrounds) { %w[light dark] }
      config_accessor(:heading_styles) { %w[none default] }
      config_accessor(:items) do
        %w[
          Katalyst::Content::Content
          Katalyst::Content::Figure
          Katalyst::Content::Section
          Katalyst::Content::Group
          Katalyst::Content::Column
          Katalyst::Content::Aside
        ]
      end
      config_accessor(:image_mime_types) { %w[image/png image/gif image/jpeg image/webp] }
      config_accessor(:max_image_size) { 20 }

      # Components
      config_accessor(:errors_component) { "Katalyst::Content::Editor::ErrorsComponent" }

      config_accessor(:base_controller) { "ApplicationController" }
    end
  end
end
