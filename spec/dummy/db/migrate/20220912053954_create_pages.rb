class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.string :slug, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
