# frozen_string_literal: true

module Katalyst
  module Content
    class Config
      attr_accessor :base_controller,
                    :default_theme,
                    :errors_component,
                    :heading_styles,
                    :image_mime_types,
                    :items,
                    :max_image_size,
                    :table_sanitizer_allowed_attributes,
                    :table_sanitizer_allowed_tags,
                    :themes

      alias_attribute :backgrounds, :themes

      def initialize
        self.themes        = %w[light dark]
        self.default_theme = themes.first

        self.heading_styles   = %w[none default]
        self.items            = %w[
          Katalyst::Content::Content
          Katalyst::Content::Figure
          Katalyst::Content::Table
          Katalyst::Content::Section
          Katalyst::Content::Group
          Katalyst::Content::Column
          Katalyst::Content::Aside
        ]
        self.image_mime_types = %w[image/png image/gif image/jpeg image/webp]
        self.max_image_size   = 20
        self.errors_component = "Katalyst::Content::Editor::ErrorsComponent"

        self.base_controller = "ApplicationController"

        # Sanitizer
        self.table_sanitizer_allowed_tags       = %w[table thead tbody tr th td caption a strong em span br p
                                                     text].freeze
        self.table_sanitizer_allowed_attributes = %w[colspan rowspan href].freeze
      end
    end
  end
end
