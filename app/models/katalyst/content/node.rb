# frozen_string_literal: true

module Katalyst
  module Content
    # Data class for representing structural information about an item
    class Node
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :id, :integer
      attribute :index, :integer
      attribute :depth, :integer, default: 0

      attr_accessor :item

      def as_json
        attributes.slice("id", "depth").as_json
      end
    end
  end
end
