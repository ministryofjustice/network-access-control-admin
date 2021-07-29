class UseCases::GenerateAuthorisedClients
  def call(clients:)
    result = ""
    clients.map do |client|
      result += "\nclient #{client.tag} {\nipv4addr = #{client.ip_range}\nsecret = #{client.shared_secret}\n}"
    end
    result += "\n"
  end
end
