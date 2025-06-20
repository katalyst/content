# frozen_string_literal: true

module Katalyst
  module Content
    module EditorHelper
      include TableHelper

      using Katalyst::HtmlAttributes::HasHtmlAttributes

      def content_editor_rich_text_attributes(attributes = {})
        {
          data: {
            direct_upload_url: direct_uploads_url,
            controller:        "content--editor--trix",
            action:            "trix-initialize->content--editor--trix#trixInitialize",
          },
        }.merge_html(attributes)
      end

      module Builder
        def content_heading_fieldset(legend: { text: "Heading" })
          govuk_fieldset(legend:) do
            concat(content_heading_field(label: { text: "Heading", class: "govuk-visually-hidden" }))
            concat(content_heading_style_field)
          end
        end

        def content_heading_field(label: { text: "Heading" }, **)
          govuk_text_field(:heading, label:, **)
        end

        def content_heading_style_field(legend: { text: "Style" }, **)
          govuk_enum_radio_buttons(:heading_style, legend:, **)
        end

        def content_url_field(label: { text: "URL" }, **)
          govuk_text_field(:url, label:, **)
        end

        def content_http_method_field(label: { text: "HTTP method" }, **)
          govuk_enum_select(:http_method, label:, **)
        end

        def content_target_field(label: { text: "HTTP target" }, **)
          govuk_enum_select(:target, label:, **)
        end

        def content_theme_field(options: { include_blank: true }, **)
          govuk_enum_select(:theme, options:, **)
        end

        def content_visible_field(label: { text: "Visible?" }, **)
          govuk_check_box_field(:visible, label:, **)
        end
      end

      class FormBuilder < ActionView::Helpers::FormBuilder
        include GOVUKDesignSystemFormBuilder::Builder
        include Builder

        delegate_missing_to :@template
      end
    end
  end
end
