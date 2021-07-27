class ChangeFilenameColumnToUniqueInCertificates < ActiveRecord::Migration[6.1]
  def change
    change_column :certificates, :filename, :text, unique: true
  end
end
