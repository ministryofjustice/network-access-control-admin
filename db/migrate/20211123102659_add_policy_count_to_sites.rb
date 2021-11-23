class AddPolicyCountToSites < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :policy_count, :bigint, null: true, default: 0
  end
end
