class UseCases::GenerateAuthorisedClients
  def call(clients:, radsec_clients:)
    output = clients.map do |client|
      client_definition(client)
    end

    output << "clients radsec {"
    if radsec_clients.any?
      output << radsec_clients.map do |client|
        radsec_client_definition(client)
      end
    end
    output << "}"

    output.join("\n")
  end

private

  def client_definition(client)
    "client #{client.ip_range} {\n\tipv4addr = #{client.ip_range}\n\tsecret = #{client.shared_secret}\n\tshortname = #{client.tag}\n}\n"
  end

  def radsec_client_definition(client)
    str = "\tclient #{client.ip_range} {"
    str << "\n\t\tipv4addr = #{client.ip_range}"
    str << "\n\t\tsecret = #{client.shared_secret}"
    str << "\n\t\tshortname = #{client.tag}"
    str << "\n\t\tproto = tls"
    str << "\n\t}\n"
  end
end
