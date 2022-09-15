# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class StatusBar < Base
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          content:change@document->#{STATUS_BAR_CONTROLLER}#change
        ACTIONS

        def build(**options)
          tag.div **default_options(**options) do
            concat status(:published, last_update: l(container.updated_at, format: :short))
            concat status(:unpublished)
            concat status(:draft)
            concat status(:dirty)
            concat actions
          end
        end

        def status(state, **options)
          tag.span(t("views.katalyst.content.editor.#{state}_html", **options),
                   class: "status-text",
                   data:  { state => "" })
        end

        def actions
          tag.menu do
            concat action(:discard, class: "button button--text")
            concat action(:revert, class: "button button--text") if container.state == :draft
            concat action(:save, class: "button button--secondary")
            concat action(:publish, class: "button button--primary")
          end
        end

        def action(action, **options)
          tag.li do
            button_tag(t("views.katalyst.content.editor.#{action}"),
                       name:  "commit",
                       value: action,
                       form:  container_form_id,
                       **options)
          end
        end

        private

        def default_options(**options)
          add_option(options, :data, :controller, STATUS_BAR_CONTROLLER)
          add_option(options, :data, :action, ACTIONS)
          add_option(options, :data, :state, container.state)

          options
        end
      end
    end
  end
end
