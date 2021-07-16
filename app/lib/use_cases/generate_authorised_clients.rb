class UseCases::GenerateAuthorisedClients
  def call(mac_authentication_bypasses:)
    mac_authentication_bypasses.map do |mab|
      mab.address
    end.join("\n")
  end
end
