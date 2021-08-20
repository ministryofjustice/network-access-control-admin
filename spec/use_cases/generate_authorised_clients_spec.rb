require "rails_helper"

describe UseCases::GenerateAuthorisedClients do
  subject(:result) do
    described_class.new.call(clients: clients)
  end

  describe "#call" do
    describe "when there are entries in the database" do
      context "and the IP ranges are IPv4" do
        let!(:site) { create(:site, name: "Another Site") }
        let!(:first_ipv4_client) { create(:client, ip_range: "123.123.0.1/24", site_id: site.id) }
        let!(:second_ipv4_client) { create(:client, ip_range: "123.123.0.2/32", site_id: site.id) }
        let(:clients) { Client.all }

        it "generates an authorised clients configuration file" do
          expected_config = "client #{first_ipv4_client.ip_range} {
\tipv4addr = #{first_ipv4_client.ip_range}
\tsecret = #{first_ipv4_client.shared_secret}
\tshortname = #{site.name.parameterize(separator: '_')}
}

client #{second_ipv4_client.ip_range} {
\tipv4addr = 123.123.0.2/32
\tsecret = #{second_ipv4_client.shared_secret}
\tshortname = #{site.name.parameterize(separator: '_')}
}"

          expect(result).to eq(expected_config)
        end
      end
    end

    describe "when there are no entries in the database" do
      let(:clients) { [] }

      it "generates an empty authorised clients configuration file" do
        expect(result).to eq("")
      end
    end
  end
end
