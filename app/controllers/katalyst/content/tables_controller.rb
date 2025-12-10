# frozen_string_literal: true

module Katalyst
  module Content
    class TablesController < ItemsController
      def update
        item.attributes = item_params

        if item.valid?
          render :update, locals: { item_editor: }
        else
          render :update, locals: { item_editor: }, status: :unprocessable_content
        end
      end
      alias_method :create, :update

      private

      def item_editor
        editor.item_editor(item:)
      end
    end
  end
end
