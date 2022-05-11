class AddContentsToCertificates < ActiveRecord::Migration[7.0]
  def change
    add_column :certificates, :contents, :text
  end
end
