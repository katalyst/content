# frozen_string_literal: true

class RenameBackgroundToTheme < ActiveRecord::Migration[8.0]
  def change
    rename_column :katalyst_content_items, :background, :theme
  end
end
