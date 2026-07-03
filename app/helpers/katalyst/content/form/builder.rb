# frozen_string_literal: true

module Katalyst
  module Content
    module Form
      module Builder
        def content_heading_fieldset(legend: {
          text: I18n.t("activerecord.attributes.katalyst/content/item.heading"),
        })
          govuk_fieldset(legend:) do
            heading = content_heading_field(label: { class: "govuk-visually-hidden" })
            style   = content_heading_style_field
            safe_join([heading, style])
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
    end
  end
end
