class UseCases::GenerateAuthorisedClients
  def call(clients:)
    output = clients.map do |client|
      "client #{client.tag.sub(" ", "_").downcase} {\n\tipv4addr = #{client.ip_range}\n\tsecret = #{client.shared_secret}\n}"
    end

    output.join("\n\n")
  end
end
