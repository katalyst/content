# frozen_string_literal: true

module Katalyst
  module Content
    module EditorHelper
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

      # When rendering item forms do not include the controller namespace prefix (katalyst/content)
      def prefix_partial_path_with_controller_namespace
        false
      end
    end
  end
end
