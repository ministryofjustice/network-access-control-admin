class Client < ApplicationRecord
  belongs_to :site

  validates_presence_of :ip_range, :shared_secret
  validate :validate_ip, on: %i[create update]
  validate :ip_range_validation_start
  validates :ip_range, presence: true, uniqueness: { scope: :radsec }
  validate :ip_range_validation_completed

private

  def validate_ip
    start_time = Time.now
    pp "IP validation started"

    return if ip_range.blank?

    unless IPAddress.valid_ipv4_subnet?(ip_range) || IPAddress.valid_ipv4?(ip_range)
      return errors.add(:ip_range, "is invalid")
    end

    ip = IPAddress::IPv4.new(ip_range)
    self.ip_range = "#{ip}/#{ip.prefix}"

    existing_clients = id.present? ? Client.where.not(id: id) : Client.all
    existing_clients.each do |client|
      next unless IP::CIDR.new(ip_range).overlaps?(IP::CIDR.new(client.ip_range)) && radsec == client.radsec

      return errors.add(:ip_range, "IP overlaps with #{client.site.name} - #{client.ip_range}")
    end

    pp "IP validation completed in #{Time.now - start_time}"
  end

  def ip_range_validation_start
    @start_time = Time.now
  end

  def ip_range_validation_completed
    pp "IP range uniqness validation completed in #{Time.now - @start_time}"
  end

  audited
end
