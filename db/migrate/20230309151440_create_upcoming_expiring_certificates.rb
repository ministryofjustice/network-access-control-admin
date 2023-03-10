class CreateUpcomingExpiringCertificates < ActiveRecord::Migration[7.0]
  def change
    create_table :upcoming_expiring_certificates do |t|
      t.date :expiry_date

      t.timestamps
    end
  end
end
