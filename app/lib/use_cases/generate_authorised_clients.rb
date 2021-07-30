class UseCases::GenerateAuthorisedClients
  def call(clients:)
    output = clients.map do |client|
      if IPAddress.valid_ipv4_subnet?(client.ip_range)
        "client #{client.ip_range} {\n\tipv4addr = #{client.ip_range}\n\tsecret = #{client.shared_secret}\n\tshortname = #{client.tag}\n}"
      else
        "client #{client.ip_range} {\n\tipv6addr = #{client.ip_range}\n\tsecret = #{client.shared_secret}\n\tshortname = #{client.tag}\n}"
      end
    end

    output.join("\n\n")
  end
end
