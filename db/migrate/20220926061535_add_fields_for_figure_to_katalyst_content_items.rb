# frozen_string_literal: true

class AddFieldsForFigureToKatalystContentItems < ActiveRecord::Migration[7.0]
  def change
    add_column :katalyst_content_items, :caption, :string
  end
end
