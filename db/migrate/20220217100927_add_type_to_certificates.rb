class AddTypeToCertificates < ActiveRecord::Migration[7.0]
  def change
    add_column :certificates, :certificate_type, :string, null: false
  end
end
