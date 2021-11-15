class AddFallbackPolicyIdToSite < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :fallback_policy_id, :bigint
  end
end
