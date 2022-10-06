# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class ImageField < Base
        IMAGE_FIELD_CONTROLLER = "content--editor--image-field"

        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          dragover->#{IMAGE_FIELD_CONTROLLER}#dragover
          dragenter->#{IMAGE_FIELD_CONTROLLER}#dragenter
          dragleave->#{IMAGE_FIELD_CONTROLLER}#dragleave
          drop->#{IMAGE_FIELD_CONTROLLER}#drop
        ACTIONS

        attr_accessor :item, :method

        def build(item, method, **options, &block)
          self.item   = item
          self.method = method

          tag.div **default_options(**options) do
            concat(capture { yield self }) if block
          end
        end

        def preview(**options)
          add_option(options, :data, "#{IMAGE_FIELD_CONTROLLER}_target", "preview")
          add_option(options, :class, "hidden") unless preview?

          tag.div **options do
            image_tag preview_url, class: "image-thumbnail"
          end
        end

        def file_input_options(options = {})
          add_option(options, :accept, config.image_mime_types.join(","))
          add_option(options, :data, :action, "change->#{IMAGE_FIELD_CONTROLLER}#onUpload")

          options
        end

        def hint_text
          t("views.katalyst.content.item.size_hint", max_size: number_to_human_size(config.max_image_size.megabytes))
        end

        def preview?
          value&.attached? && value&.persisted?
        end

        def preview_url
          preview? ? main_app.url_for(value) : ""
        end

        def value
          item.send(method)
        end

        private

        def default_options(**options)
          add_option(options, :data, :controller, IMAGE_FIELD_CONTROLLER)
          add_option(options, :data, :action, ACTIONS)
          add_option(options, :data, :"#{IMAGE_FIELD_CONTROLLER}_mime_types_value",
                     config.image_mime_types.to_json)
          add_option(options, :data, :"#{IMAGE_FIELD_CONTROLLER}_max_size_value",
                     config.max_image_size.megabytes)

          options
        end
      end
    end
  end
end
