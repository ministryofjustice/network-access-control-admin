module CSVImport
  class MacAuthenticationBypass < MacAuthenticationBypass
    def validate_uniqueness_of_address(list_of_mac_addresses)
      errors.add(:address, "has already taken") unless address.nil? || list_of_mac_addresses.count(address) == 1
    end

    def skip_uniqueness_validation?
      true
    end
  end
end
