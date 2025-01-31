# frozen_string_literal: true

module Katalyst
  module Content
    class ItemsController < Katalyst::Content.config.base_controller.constantize
      before_action :set_container, only: %i[new create]
      before_action :set_item, except: %i[new create]
      before_action :set_editor_variant
      before_action :require_kpop, only: %i[new edit]

      attr_reader :container, :item, :editor

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
        type = params.require(:item).fetch(:type, "")
        if Katalyst::Content.config.items.include?(type)
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
      # Note: this idea comes from various blogs who have documented this approach, such as
      # https://medium.com/@TETRA2000/active-storage-how-to-retain-uploaded-files-on-form-resubmission-91b57be78d53
      #
      # In Rails 7.2 the simple version of this approach was broken to work around a bug that Rails plans to address
      # in a future release.
      # https://github.com/rails/rails/commit/82d4ad5da336a18a55a05a50b851e220032369a0
      #
      # The work around is to decouple the blobs from their attachments before saving by duping
      # them. This approach feels a bit hairy and might need to be replaced by a 'standard' direct upload approach
      # in the future.
      #
      # The reason we use this approach currently is to avoid needing a separate direct upload controller for
      # content which would potentially introduce a back door where un-trusted users are allowed to upload
      # attachments.
      def store_attachments(item)
        item.attachment_changes.each_value do |change|
          case change
          when ActiveStorage::Attached::Changes::CreateOne
            change.upload
            change.attachment.blob = change.blob.dup.tap(&:save!)
          when ActiveStorage::Attached::Changes::CreateMany
            change.upload
            change.attachments.zip(change.blobs).each do |attachment, blob|
              attachment.blob = blob.dup.tap(&:save!)
            end
          end
        end
      end

      # When rendering item forms do not include the controller namespace prefix (katalyst/content)
      def prefix_partial_path_with_controller_namespace
        false
      end

      def kpop_fallback_location
        main_app.root_path
      end
    end
  end
end
