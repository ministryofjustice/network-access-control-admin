class AddCertificateFilenameToCertificates < ActiveRecord::Migration[6.1]
  def change
    add_column :certificates, :filename, :text, null: false
  end
end
