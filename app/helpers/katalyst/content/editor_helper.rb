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
        def content_heading_fieldset(legend: { text: t("activerecord.attributes.katalyst/content/item.heading") })
          govuk_fieldset(legend:) do
            concat(content_heading_field(label: { class: "govuk-visually-hidden" }))
            concat(content_heading_style_field)
          end
        end

        def content_heading_field(**)
          govuk_text_field(:heading, **)
        end

        def content_heading_style_field(**)
          govuk_enum_select(:heading_style, **)
        end

        def content_url_field(**)
          govuk_text_field(:url, **)
        end

        def content_http_method_field(**)
          govuk_enum_select(:http_method, **)
        end

        def content_target_field(**)
          govuk_enum_select(:target, **)
        end

        def content_theme_field(options: { include_blank: true }, **)
          govuk_enum_select(:theme, options:, **)
        end

        def content_visible_field(**)
          govuk_check_box_field(:visible, **)
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
