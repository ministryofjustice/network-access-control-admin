class AddPriorityToSitePolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :policies_sites, :id, :primary_key
    add_column :policies_sites, :priority, :integer
  end
end
