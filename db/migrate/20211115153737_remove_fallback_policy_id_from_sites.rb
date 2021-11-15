class RemoveFallbackPolicyIdFromSites < ActiveRecord::Migration[6.1]
  def change
    remove_column :sites, :fallback_policy_id, :bigint
  end
end
