# frozen_string_literal: true

class AddStyleToContentItems < ActiveRecord::Migration[7.1]
  def change
    add_column :katalyst_content_items, :style, :json, null: false, default: {}
  end
end
