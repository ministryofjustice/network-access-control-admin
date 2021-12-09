class Client < ApplicationRecord
  belongs_to :site

  validates_presence_of :ip_range, :shared_secret
  validate :validate_ip, on: %i[create update]
  validates :ip_range, presence: true, uniqueness: { scope: :radsec }

private

  def validate_ip
    return if ip_range.blank?

    unless IPAddress.valid_ipv4_subnet?(ip_range)
      return errors.add(:ip_range, "is invalid")
    end

    Client.all.each do |client|
      if IP::CIDR.new(ip_range).overlaps?(IP::CIDR.new(client.ip_range))
        return errors.add(:ip_range, "IP overlaps with #{client.site.name} - #{client.ip_range}")
      end
    end
  end

  audited
end
