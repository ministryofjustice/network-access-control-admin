class AddSitesToPoliciesTable < ActiveRecord::Migration[6.1]
  def change
    change_table :policies do |t|
      t.belongs_to :site
    end
  end
end
