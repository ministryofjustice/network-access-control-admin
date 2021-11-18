class AddExtensionsColumnToCertificates < ActiveRecord::Migration[6.1]
  def change
    add_column :certificates, :extensions, :text
  end
end
