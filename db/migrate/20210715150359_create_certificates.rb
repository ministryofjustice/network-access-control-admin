class CreateCertificates < ActiveRecord::Migration[6.1]
  def change
    create_table :certificates do |t|
      t.string :name, null: false, unique: true
      t.text :description, null: false
      t.date :expiry_date
      t.text :subject

      t.timestamps
    end
  end
end
