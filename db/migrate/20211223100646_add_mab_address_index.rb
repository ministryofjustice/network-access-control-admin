class AddMabAddressIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :mac_authentication_bypasses, :address
  end
end
