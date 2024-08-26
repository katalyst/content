# frozen_string_literal: true

module Katalyst
  module Content
    module Types
      # Data serialization/deserialization for Katalyst::Content::Item style data
      class StyleType < ActiveRecord::Type::Json
        def initialize(type)
          super()

          @type = type
        end

        def serialize(value)
          super(value.attributes)
        end

        def deserialize(value)
          case value
          when String
            decoded = super
            @type.new(**decoded) unless decoded.nil?
          when Hash
            @type.new(**value)
          when HasStyle::StyleBase
            value
          end
        end
      end
    end
  end
end
