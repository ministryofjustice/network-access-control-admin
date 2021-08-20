class UseCases::GenerateAuthorisedClients
  def call(clients:)
    output = clients.map do |client|
      client_definition(client)
    end

    output.join("\n\n")
  end

private

  def client_definition(client)
    site_tag = Site.find_by_id(client.site_id).name.parameterize(separator: "_")
    "client #{client.ip_range} {\n\tipv4addr = #{client.ip_range}\n\tsecret = #{client.shared_secret}\n\tshortname = #{site_tag}\n}"
  end
end
