class CreateSitePolicy < ActiveRecord::Migration[6.1]
  def change
    create_table :site_policies do |t|
      t.bigint :site_id
      t.bigint :policy_id
      t.integer :priority

      t.timestamps
    end

    drop_table :policies_sites
  end
end
