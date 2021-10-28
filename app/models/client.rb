class Client < ApplicationRecord
  belongs_to :site

  validates_presence_of :ip_range, :shared_secret
  validate :validate_ip, on: :create
  validates :ip_range, presence: true, uniqueness: { scope: :radsec }

private

  def validate_ip
    return if ip_range.blank?

    errors.add(:ip_range, "is invalid") unless IPAddress.valid_ipv4_subnet?(ip_range)
  end

  audited
end
