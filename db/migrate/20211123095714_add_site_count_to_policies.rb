class AddSiteCountToPolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :policies, :site_count, :bigint, null: true, default: 0
  end
end
