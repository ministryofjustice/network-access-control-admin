class CreateVlans < ActiveRecord::Migration[6.1]
  def change
    create_table :vlans do |t|
      t.integer :vlan, null: false
      t.string :common_name, null: false, unique: true
      t.string :remote_ip, null: false

      t.timestamps
    end
  end
end
