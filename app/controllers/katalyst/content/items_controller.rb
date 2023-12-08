# frozen_string_literal: true

module Katalyst
  module Content
    class ItemsController < ApplicationController
      before_action :set_container, only: %i[new create]
      before_action :set_item, except: %i[new create]
      before_action :set_editor_variant

      attr_reader :container, :item, :editor

      helper EditorHelper

      layout nil

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
        params.require(:item).permit(item_params_type.permitted_params)
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
    end
  end
end
