class UseCases::GenerateAuthorisedClients
  def call(clients:)
    output = clients.map do |client|
      client_definition(client)
    end

    output.join("\n\n")
  end

private

  def client_definition(client)
    "client #{client.ip_range} {\n\tipv4addr = #{client.ip_range}\n\tsecret = #{client.shared_secret}\n\tshortname = #{client.tag}\n}"
  end
end
