# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class StatusBarComponent < BaseComponent
        ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
          content:change@document->#{STATUS_BAR_CONTROLLER}#change
          turbo:morph-element->#{STATUS_BAR_CONTROLLER}#morph
        ACTIONS

        attr_reader :container

        def call
          tag.div(**html_attributes) do
            concat status(:published, last_update: l(container.updated_at, format: :short))
            concat status(:unpublished)
            concat status(:draft)
            concat status(:dirty)
            concat actions
          end
        end

        def status(state, **)
          status_text  = t("views.katalyst.content.editor.#{state}_html", **)
          html_options = { class: "status-text", data: { state => "", turbo: false } }

          case state
          when :published
            link_to status_text, url_for(container), **html_options
          when :unpublished, :draft
            link_to status_text, "#{url_for(container)}/preview", **html_options
          else
            tag.span status_text, **html_options
          end
        end

        def actions
          tag.menu do
            concat action(:discard, class: "button button--text")
            concat action(:revert, class: "button button--text") if container.state == :draft
            concat action(:save, class: "button button--secondary")
            concat action(:publish, class: "button button--primary")
          end
        end

        def action(action, **)
          tag.li do
            button_tag(t("views.katalyst.content.editor.#{action}"),
                       name:  "commit",
                       value: action,
                       form:  container_form_id,
                       **)
          end
        end

        private

        def default_html_attributes
          {
            data: {
              controller: STATUS_BAR_CONTROLLER,
              action:     ACTIONS,
              state:      container.state,
            },
          }
        end
      end
    end
  end
end
