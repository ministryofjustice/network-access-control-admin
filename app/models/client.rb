class Client < ApplicationRecord
  belongs_to :site

  validates_presence_of :ip_range, :shared_secret
  validates_uniqueness_of :ip_range
  validate :validate_ip, on: :create

  before_save :generate_tag

private

  def validate_ip
    return if ip_range.blank?

    errors.add(:ip_range, "is invalid") unless IPAddress.valid_ipv4_subnet?(ip_range)
  end

  def generate_tag
    self.tag = site.name.parameterize(separator: "_")
  end

  audited
end
