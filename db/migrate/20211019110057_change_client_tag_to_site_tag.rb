class ChangeClientTagToSiteTag < ActiveRecord::Migration[6.1]
  def self.up
    add_column :sites, :tag, :string, null: false
    execute "UPDATE sites s, clients c SET s.tag = c.tag WHERE s.id = c.site_id"
    remove_column :clients, :tag
  end

  def self.down
    add_column :clients, :tag, :string, null: false
    execute "UPDATE clients c, sites s SET c.tag = s.tag WHERE c.site_id = s.id"
    remove_column :sites, :tag
  end
end
