# frozen_string_literal: true

module Katalyst
  module Content
    module Editor
      class StatusBarComponent < BaseComponent
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

          case state.to_sym
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
            concat action(:discard, class: "button", data: { text_button: "" })
            concat action(:revert, class: "button", data: { text_button: "" })
            concat action(:save, class: "button", data: { ghost_button: "" })
            concat action(:publish, class: "button")
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
              controller: "content--editor--status-bar",
              action:     %w[
                content:change@document->content--editor--status-bar#change
                turbo:morph-element->content--editor--status-bar#morph
              ],
              state:      container.state,
            },
          }
        end
      end
    end
  end
end
