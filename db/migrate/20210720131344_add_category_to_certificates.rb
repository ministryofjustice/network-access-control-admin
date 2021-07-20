class AddCategoryToCertificates < ActiveRecord::Migration[6.1]
  def change
    add_column :certificates, :category, :string, null: false
  end
end
