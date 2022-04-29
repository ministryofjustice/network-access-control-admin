class AddActionToPolicies < ActiveRecord::Migration[7.0]
  def change
    add_column :policies, :action, :string, default: "accept"
  end
end
