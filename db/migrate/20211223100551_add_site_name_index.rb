class AddSiteNameIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :sites, :name
  end
end
