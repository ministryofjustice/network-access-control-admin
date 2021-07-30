class UseCases::GenerateAuthorisedClients
  def call(clients:)
    output = clients.map do |client|
      client_definition(client)
    end

    output.join("\n\n")
  end

private

  def client_definition(client)
    "client #{client.ip_range} {\n\t#{ip_version(client.ip_range)} = #{client.ip_range}\n\tsecret = #{client.shared_secret}\n\tshortname = #{client.tag}\n}"
  end

  def ip_version(ip_range)
    IPAddress.valid_ipv4_subnet?(ip_range) ? "ipv4addr" : "ipv6addr"
  end
end
