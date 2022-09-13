# frozen_string_literal: true

class CreateKatalystContentItems < ActiveRecord::Migration[7.0]
  def change
    create_table :katalyst_content_items do |t|
      t.string :type
      t.belongs_to :container, polymorphic: true

      t.string :heading, null: false
      t.boolean :show_heading, null: false, default: true
      t.string :background, null: false

      t.timestamps
    end
  end
end
