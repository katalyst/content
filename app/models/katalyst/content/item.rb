# frozen_string_literal: true

module Katalyst
  module Content
    # STI base class for content items
    class Item < ApplicationRecord
      include HasStyle

      def self.config
        Katalyst::Content.config
      end

      enum :heading_style, config.heading_styles, prefix: :heading

      belongs_to :container, polymorphic: true

      validates :heading, presence: true
      validates :heading_style, inclusion: { in: config.heading_styles }
      validates :theme, inclusion: { in: config.themes, allow_blank: true }

      after_initialize :initialize_tree
      before_validation :set_defaults

      attr_accessor :parent, :children, :index, :depth, :previous_sibling, :next_sibling

      def self.permitted_params
        %i[
          container_type
          container_id
          type
          heading
          heading_style
          theme
          visible
        ]
      end

      def to_plain_text
        heading if show_heading? && visible?
      end

      def show_heading?
        !heading_none?
      end

      def heading_style_class
        heading_style unless heading_default?
      end

      def layout?
        is_a? Layout
      end

      def dom_id
        heading&.parameterize
      end

      def item_type
        model_name.param_key
      end

      def theme
        super.presence || parent&.theme
      end

      private

      def initialize_tree
        self.parent   ||= nil
        self.children ||= []
      end

      def set_defaults
        self.heading_style = "none" if heading_style.blank?
      end
    end
  end
end
