# frozen_string_literal: true

module Katalyst
  module Content
    class ItemsController < Katalyst::Content.config.base_controller.constantize
      before_action :set_container, only: %i[new create]
      before_action :set_item, except: %i[new create]
      before_action :set_editor_variant

      attr_reader :container, :item, :editor

      default_form_builder "Katalyst::Content::EditorHelper::FormBuilder"

      helper EditorHelper

      def new
        render_editor
      end

      def edit
        render_editor
      end

      def create
        if item.save
          render :update, locals: { editor:, item:, previous: @container.items.build(type: item.type) }
        else
          store_attachments(item)

          render_editor status: :unprocessable_entity
        end
      end

      def update
        @item.attributes = item_params

        if @item.valid?
          previous = @item
          @item    = @item.dup.tap(&:save!)

          render locals: { editor:, item:, previous: }
        else
          store_attachments(item)

          render_editor status: :unprocessable_entity
        end
      end

      private

      def item_params_type
        requested_type = params.require(:item).fetch(:type, "")
        if (type = Katalyst::Content.config.items.find { |t| t == requested_type })
          type.safe_constantize
        else
          Item
        end
      end

      def item_params
        params.expect(item: item_params_type.permitted_params)
      end

      def set_container
        @container = Item.new(item_params).container
        raise ActiveRecord::RecordNotFound unless @container

        @item   = @container.items.build(item_params)
        @editor = Katalyst::Content::EditorComponent.new(container:, item:)
      end

      def set_item
        @item      = Item.find(params[:id])
        @container = @item.container
        @editor = Katalyst::Content::EditorComponent.new(container:, item:)
      end

      def set_editor_variant
        request.variant << :form
      end

      def render_editor(**)
        render(:edit, locals: { item_editor: editor.item_editor(item:) }, **)
      end

      # Ensure that any attachments are stored before the item is returned to
      # the editor, so that uploads are not lost if the item is invalid.
      #
      # This mimics the behaviour of direct uploads without requiring the JS
      # integration.
      #
      # The reason we use this approach currently is to avoid needing a separate direct upload controller for
      # content which would potentially introduce a back door where un-trusted users are allowed to upload
      # attachments.
      def store_attachments(item)
        item.attachment_changes.each_value do |change|
          case change
          when ActiveStorage::Attached::Changes::CreateOne
            change.upload
            change.blob.save!
          when ActiveStorage::Attached::Changes::CreateMany
            change.upload
            change.blobs.each(&:save!)
          end
        end
      end

      # When rendering item forms do not include the controller namespace prefix (katalyst/content)
      def prefix_partial_path_with_controller_namespace
        false
      end
    end
  end
end
