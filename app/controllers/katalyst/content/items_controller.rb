# frozen_string_literal: true

module Katalyst
  module Content
    class ItemsController < ApplicationController
      before_action :set_container, only: %i[new create]
      before_action :set_item, except: %i[new create]
      before_action :set_editor_variant

      helper EditorHelper

      def new
        render locals: { item: @container.items.build(item_params) }
      end

      def edit
        render locals: { item: @item }
      end

      def create
        @item = item = @container.items.build(item_params)
        if item.save
          render :update, locals: { item:, previous: @container.items.build(type: item.type) }
        else
          render :new, status: :unprocessable_entity, locals: { item: }
        end
      end

      def update
        @item.attributes = item_params

        if @item.valid?
          previous = @item
          @item    = @item.dup.tap(&:save!)
          render locals: { item: @item, previous: }
        else
          render :edit, status: :unprocessable_entity, locals: { item: @item }
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
      end

      def set_item
        @item = Item.find(params[:id])
      end

      def set_editor_variant
        request.variant << :form
      end
    end
  end
end
