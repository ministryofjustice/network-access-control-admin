# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.boolean :editor, default: false
      t.string :email
      t.timestamps null: false
    end
  end
end
