module ApplicationRecordHelper
  def trim_white_space(*attr)
    attr.each { |a| a.strip! if a.present? }
  end

  def validate_radius_attribute(attribute, value, operator = nil)
    return if attribute.blank? || errors.key?(attribute.to_sym)

    result = UseCases::ValidateRadiusAttribute.new.call(attribute:, value:, operator:)

    unless result.fetch(:success)
      errors.add(:base, result.fetch(:message))
    end
  end

  def format_ip_range(ip_range)
    ip = IPAddress::IPv4.new(ip_range)
    "#{ip}/#{ip.prefix}"
  end

  def valid_ip_range?(ip_range)
    IPAddress.valid_ipv4_subnet?(ip_range) || IPAddress.valid_ipv4?(ip_range)
  end
end
