class CreateRules < ActiveRecord::Migration[6.1]
  def change
    create_table :request_attributes do |t|
      t.string :key
    end

    create_table :rules do |t|
      t.string :operator, null: false
      t.string :value, null: false
      t.belongs_to :policy, null: false, foreign_key: true
      t.references :request_attribute, null: false, foreign_key: true

      t.timestamps
    end
  end
end
