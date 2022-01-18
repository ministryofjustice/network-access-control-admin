class Client < ApplicationRecord
  belongs_to :site

  validates_presence_of :ip_range, :shared_secret
  validate :validate_ip, on: %i[create update]
  validates :ip_range, presence: true, uniqueness: { scope: :radsec }

  before_save :append_ip_range

private

  def validate_ip
    return if ip_range.blank?

    unless IPAddress.valid_ipv4_subnet?(ip_range) || IPAddress.valid_ipv4?(ip_range)
      return errors.add(:ip_range, "is invalid")
    end

    existing_clients = id.present? ? Client.where.not(id: id) : Client.all
    existing_clients.each do |client|
      next unless IP::CIDR.new(ip_range).overlaps?(IP::CIDR.new(client.ip_range)) && radsec == client.radsec

      return errors.add(:ip_range, "IP overlaps with #{client.site.name} - #{client.ip_range}")
    end
  end

  def append_ip_range
    return if ip_range.nil?

    ip = IPAddress::IPv4.new(ip_range)
    self.ip_range = "#{ip}/#{ip.prefix}"
  end

  audited
end
