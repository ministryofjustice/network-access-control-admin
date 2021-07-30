class UseCases::GenerateAuthorisedClients
  def call(clients:)
    output = clients.map do |client|
      if IPAddress.valid_ipv6_subnet? client.ip_range
        "client #{client.tag.sub(" ", "_").downcase} {\n\tipv6addr = #{client.ip_range}\n\tsecret = #{client.shared_secret}\n}"
      else
        "client #{client.tag.sub(" ", "_").downcase} {\n\tipv4addr = #{client.ip_range}\n\tsecret = #{client.shared_secret}\n}"
      end
    end

    output.join("\n\n")
  end
end
