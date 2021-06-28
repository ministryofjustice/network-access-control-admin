class Ipv4ListValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, ip_addresses)
    unless ip_addresses.all? { |ip_address| IPAddress.valid_ipv4?(ip_address) }
      record.errors.add(
        attribute,
        options[:message] || "contains an invalid IPv4 address"
      )
    end
  end
end
