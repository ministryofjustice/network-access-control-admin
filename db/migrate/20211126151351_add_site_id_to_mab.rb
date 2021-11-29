class AddSiteIdToMab < ActiveRecord::Migration[6.1]
  def change
    change_table :mac_authentication_bypasses do |t|
      t.belongs_to :site, null: true, foreign_key: true
    end
  end
end
