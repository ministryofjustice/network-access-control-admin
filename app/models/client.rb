class Client < ApplicationRecord
  SHARED_SECRET_BYTES = 10
  RADSEC_SHARED_SECRET = "radsec".freeze

  belongs_to :site

  after_initialize :generate_shared_secret

  validates_presence_of :ip_range, :shared_secret
  validate :validate_ip
  validates :ip_range, presence: true, uniqueness: { scope: :radsec }
  validate :validate_ip_range_overlap, on: %i[create update]

private

  def validate_ip
    return if ip_range.blank?

    unless IPAddress.valid_ipv4_subnet?(ip_range) || IPAddress.valid_ipv4?(ip_range)
      return errors.add(:ip_range, "is invalid")
    end

    ip = IPAddress::IPv4.new(ip_range)
    self.ip_range = "#{ip}/#{ip.prefix}"
  end

  def validate_ip_range_overlap
    return if ip_range.blank? || errors[:ip_range].any?

    existing_clients = id.present? ? Client.where.not(id: id) : Client.all
    existing_clients.each do |client|
      next unless IP::CIDR.new(ip_range).overlaps?(IP::CIDR.new(client.ip_range)) && radsec == client.radsec

      return errors.add(:ip_range, "IP overlaps with #{client.site.name} - #{client.ip_range}")
    end
  end

  def generate_shared_secret
    return if shared_secret.present?

    self.shared_secret = radsec? ? RADSEC_SHARED_SECRET : SecureRandom.hex(SHARED_SECRET_BYTES).upcase
  end

  audited
end
