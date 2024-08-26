# frozen_string_literal: true

module Katalyst
  module Content
    module HasStyle
      extend ActiveSupport::Concern

      # Style attribute allows items to define their own attributes for use in
      # content styles. These attribute will be automatically mapped to json
      # data which is stored and deserialized without needing to add columns.
      class_methods do
        def style_attributes(&)
          style_class = Class.new(Katalyst::Content::HasStyle::StyleBase, &)
          const_set(:Style, style_class)
          attribute(:style, Katalyst::Content::Types::StyleType.new(style_class), default: -> { style_class.new })

          style_class.attribute_names.each do |name|
            define_method(name) { style.public_send(name) }
            define_method(:"#{name}=") { |value| style.public_send(:"#{name}=", value) }
          end

          validate do
            style.validate(validation_context)
            style.errors.each do |error|
              errors.add(error.attribute, error.type)
            end
          end
        end
      end

      class StyleBase
        include ActiveModel::Model
        include ActiveModel::Attributes
      end
    end
  end
end
