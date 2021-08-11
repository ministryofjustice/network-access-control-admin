class CreatePoliciesSitesJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :policies, :sites do |t|
      t.index :policy_id
      t.index :site_id
    end
  end
end
