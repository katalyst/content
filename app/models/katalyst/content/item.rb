# frozen_string_literal: true

module Katalyst
  module Content
    # STI base class for content items
    class Item < ApplicationRecord
      def self.config
        Katalyst::Content.config
      end

      belongs_to :container, polymorphic: true

      validates :heading, presence: true
      validates :background, presence: true, inclusion: { in: config.backgrounds }

      after_initialize :initialize_tree

      attr_accessor :parent, :children, :index, :depth

      def self.permitted_params
        %i[
          container_type
          container_id
          type
          heading
          show_heading
          background
          visible
        ]
      end

      def to_plain_text
        heading if show_heading? && visible?
      end

      private

      def initialize_tree
        self.parent   ||= nil
        self.children ||= []
      end
    end
  end
end
