class AddDefaultTimestampSitePolicies < ActiveRecord::Migration[6.1]
  def change
    change_table :site_policies do |t|
      t.change :created_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
      t.change :updated_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end
