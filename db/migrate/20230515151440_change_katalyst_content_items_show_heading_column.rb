# frozen_string_literal: true

class ChangeKatalystContentItemsShowHeadingColumn < ActiveRecord::Migration[7.0]
  # rubocop:disable Rails/SkipsModelValidations
  def up
    add_column :katalyst_content_items, :heading_style, :integer, null: false, default: 0
    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE katalyst_content_items SET heading_style = 1 WHERE show_heading = true;
    SQL
    remove_column :katalyst_content_items, :show_heading, :boolean
  end
  # rubocop:enable Rails/SkipsModelValidations

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
