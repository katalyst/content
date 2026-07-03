# frozen_string_literal: true

module Katalyst
  module Content
    module EditorHelper
      include TableHelper

      class FormBuilder < ActionView::Helpers::FormBuilder
        include GOVUKDesignSystemFormBuilder::Builder
        include Katalyst::Content::Form::Builder

        delegate :content_tag, :tag, :safe_join, :link_to, :capture, to: :@template
      end

      # @deprecated no longer required
      def content_editor_rich_text_attributes(attributes = {})
        attributes
      end

      private

      def instantiate_builder(record_name, record_object, options, &)
        super.tap do |builder|
          builder.extend(Katalyst::Content::Form::Builder) unless builder.is_a?(Katalyst::Content::Form::Builder)
        end
      end

      # Provides a compatible formbuilder if the default does not include GovUK
      # @api internal
      # @see ActionView::Helpers::FormHelper#default_form_builder_class
      def default_form_builder_class
        builder = super
        builder.include?(GOVUKDesignSystemFormBuilder::Builder) ? builder : FormBuilder
      end
    end
  end
end
