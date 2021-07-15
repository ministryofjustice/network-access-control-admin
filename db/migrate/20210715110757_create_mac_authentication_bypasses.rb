class CreateMacAuthenticationBypasses < ActiveRecord::Migration[6.1]
  def change
    create_table :mac_authentication_bypasses do |t|
      t.string :address, null: false, unique: true
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
