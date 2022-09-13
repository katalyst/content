# frozen_string_literal: true

class CreatePageVersions < ActiveRecord::Migration[7.0]
  def change
    create_table :page_versions do |t|
      t.references :parent, foreign_key: { to_table: :pages }, null: false
      t.json :nodes

      t.timestamps
    end

    change_table :pages do |t|
      t.references :published_version, foreign_key: { to_table: :page_versions }
      t.references :draft_version, foreign_key: { to_table: :page_versions }
    end
  end
end
