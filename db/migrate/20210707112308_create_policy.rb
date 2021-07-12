# frozen_string_literal: true

class CreatePolicy < ActiveRecord::Migration[6.1]
  def change
    create_table :policies do |t|
      t.string :name, null: false, unique: true
      t.text :description, null: false

      t.timestamps
    end
  end
end
