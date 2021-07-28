class CreateClients < ActiveRecord::Migration[6.1]
  def change
    create_table :clients do |t|
      t.string :tag, null: false
      t.string :shared_secret, null: false
      t.string :ip_range, null: false
      t.belongs_to :site, null: false, foreign_key: true

      t.timestamps
    end
  end
end
