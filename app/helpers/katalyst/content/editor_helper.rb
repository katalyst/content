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
    end
  end
end
