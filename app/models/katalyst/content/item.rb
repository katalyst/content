# frozen_string_literal: true

module Katalyst
  module Content
    # STI base class for content items
    class Item < ApplicationRecord
      def self.config
        Katalyst::Content.config
      end

      enum :heading_style, config.heading_styles, prefix: :heading

      belongs_to :container, polymorphic: true

      validates :heading, presence: true
      validates :heading_style, inclusion: { in: config.heading_styles }
      validates :background, presence: true, inclusion: { in: config.backgrounds }, if: :validate_background?

      after_initialize :initialize_tree
      before_validation :set_defaults

      attr_accessor :parent, :children, :index, :depth

      def self.permitted_params
        %i[
          container_type
          container_id
          type
          heading
          heading_style
          background
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

      private

      def initialize_tree
        self.parent   ||= nil
        self.children ||= []
      end

      def set_defaults
        self.heading_style = "none" if heading_style.blank?
      end

      def validate_background?
        true
      end
    end
  end
end
