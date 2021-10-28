class AddRadsecToClients < ActiveRecord::Migration[6.1]
  def change
    add_column :clients, :radsec, :boolean, null: false
    execute "UPDATE clients c SET c.radsec = 1 WHERE c.shared_secret = 'radsec'"
    execute "UPDATE clients c SET c.radsec = 0 WHERE c.shared_secret != 'radsec'"
  end
end
