class UseCases::GenerateAuthorisedClients
  def call(clients:, radsec_clients:)
    output = clients.map do |client|
      client_definition(client)
    end

    if radsec_clients.any?
      output << "clients radsec {"
      output << radsec_clients.map do |client|
        radsec_client_definition(client)
      end
      output << "}"
    end

    output.join("\n")
  end

private

  def client_definition(client)
    "client #{client.ip_range} {\n\tipv4addr = #{client.ip_range}\n\tsecret = #{client.shared_secret}\n\tshortname = #{client.tag}\n}\n"
  end

  def radsec_client_definition(client)
    "\tclient #{client.ip_range} {\n\t\tipv4addr = #{client.ip_range}\n\t\tsecret = #{client.shared_secret}\n\t\tshortname = #{client.tag}\n\t}\n"
  end
end
