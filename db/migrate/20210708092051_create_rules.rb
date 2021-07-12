# frozen_string_literal: true

class CreateRules < ActiveRecord::Migration[6.1]
  def change
    create_table :rules do |t|
      t.string :operator, null: false
      t.string :value, null: false
      t.belongs_to :policy, null: false, foreign_key: true
      t.string :request_attribute, null: false

      t.timestamps
    end
  end
end
