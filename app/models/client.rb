class Client < ApplicationRecord
  belongs_to :site

  validates_presence_of :ip_range, :shared_secret
  validates_uniqueness_of :ip_range
  validate :validate_ip, on: :create

  def radsec?
    shared_secret == "radsec"
  end

private

  def validate_ip
    return if ip_range.blank?

    errors.add(:ip_range, "is invalid") unless IPAddress.valid_ipv4_subnet?(ip_range)
  end

  audited
end
