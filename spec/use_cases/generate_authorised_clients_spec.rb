require "rails_helper"

describe UseCases::GenerateAuthorisedClients do
  subject(:result) do
    described_class.new.call(clients: clients)
  end

  describe "#call" do
    describe "When there are entries in the database" do
      let(:first_client) { create(:client, ip_range: "123.123.0.1") }
      let(:second_client) { create(:client, ip_range: "123.123.0.2") }
      let(:clients) { Client.all }

      it "generates a authorised_clients configuration file" do
        expected_config = """
client #{first_client.tag} {
ipv4addr = 123.123.0.1
secret = #{first_client.shared_secret}
}
client #{second_client.tag} {
ipv4addr = 123.123.0.2
secret = #{second_client.shared_secret}
}
"""

        expect(result).to include(expected_config)
      end
    end

    # describe "When there are no entries in the database" do
    #   let(:mac_authentication_bypasses) { [] }

    #   it "generates an empty authorised_clients configuration file" do
    #     expect(result).to eq("")
    #   end
    # end
  end
end
