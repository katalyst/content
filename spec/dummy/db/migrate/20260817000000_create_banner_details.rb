# frozen_string_literal: true

class CreateBannerDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :banner_details do |t|
      t.references :detailable, polymorphic: true, index: true
      t.string :analytics_title

      t.timestamps
    end

    create_table :banner_notes do |t|
      t.references :notable, polymorphic: true, index: true
      t.string :note

      t.timestamps
    end
  end
end
