class AddMabIdToResponses < ActiveRecord::Migration[6.1]
  def change
    change_table :responses do |t|
      t.belongs_to :mac_authentication_bypass, foreign_key: true
      t.remove_references :policy
      t.belongs_to :policy, foreign_key: true
    end
  end
end
