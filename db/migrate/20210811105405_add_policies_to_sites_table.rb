class AddPoliciesToSitesTable < ActiveRecord::Migration[6.1]
  def change
    change_table :sites do |t|
      t.belongs_to :policy
    end
  end
end
