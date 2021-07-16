class UseCases::GenerateAuthorisedClients
  def call(mac_authentication_bypasses:)
    mac_authentication_bypasses.map { |mab|
      mab.address
    }.join("\n")
  end
end
