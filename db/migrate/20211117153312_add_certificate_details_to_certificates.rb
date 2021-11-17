class AddCertificateDetailsToCertificates < ActiveRecord::Migration[6.1]
  def change
    add_column :certificates, :issuer, :text
    add_column :certificates, :serial, :text
  end
end
