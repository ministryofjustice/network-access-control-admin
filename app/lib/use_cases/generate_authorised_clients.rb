class UseCases::GenerateAuthorisedClients
  def call(mac_authentication_bypasses:)
    mac_authentication_bypasses.map(&:address).join("\n")
  end
end
