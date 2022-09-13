# frozen_string_literal: true

module Katalyst
  module Content
    # STI base class for content items
    class Item < ApplicationRecord
      belongs_to :container, polymorphic: true

      validates :heading, presence: true
      validates :background, presence: true, inclusion: { in: Katalyst::Content.config.backgrounds }

      after_initialize :initialize_tree

      attr_accessor :parent, :children, :index, :depth

      private

      def initialize_tree
        self.parent   ||= nil
        self.children ||= []
      end
    end
  end
end
