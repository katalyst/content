# frozen_string_literal: true

class RemoveNotNullOnKatalystContentItemsTheme < ActiveRecord::Migration[8.0]
  def change
    change_column_null :katalyst_content_items, :theme, true
  end
end
