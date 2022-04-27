class AddDefaultAcceptToPolicies < ActiveRecord::Migration[7.0]
  def change
    add_column :policies, :default_accept, :boolean, default: true
  end
end
