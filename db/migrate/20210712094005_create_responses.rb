# frozen_string_literal: true

class CreateResponses < ActiveRecord::Migration[6.1]
  def change
    create_table :responses do |t|
      t.belongs_to :policy, null: false, foreign_key: true

      t.string :response_attribute, null: false
      t.string :value, null: false

      t.timestamps
    end
  end
end
