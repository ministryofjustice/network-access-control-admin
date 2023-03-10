class UpcomingExpiringCertificate < ApplicationRecord
  validates :expiry_date, presence: true
end
