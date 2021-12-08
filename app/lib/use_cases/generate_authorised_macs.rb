class UseCases::GenerateAuthorisedMacs
  def call(mac_authentication_bypasses:)
    bypasses = mac_authentication_bypasses.map do |bypass|
      responses = bypass.responses.map { |response| [response.response_attribute, "\"#{response.value}\""].join(" = ") }.join(",\n        ")
      bypass_address_line = "#{bypass.address} Cleartext-Password := #{normalised_password(bypass.address)}"

      bypass.responses.empty? ? bypass_address_line : [bypass_address_line, responses].join("\n        ")
    end

    "#{bypasses.join("\n\n")}\n"
  end

private

  def normalised_password(mac_address)
    mac_address.gsub("-", "")
  end
end
