require "rails_helper"

describe UseCases::GenerateAuthorisedClients do
  subject(:result) do
    described_class.new.call(clients: clients, radsec_clients: radsec_clients)
  end

  describe "#call" do
    describe "when there are entries in the database" do
      context "and the IP ranges are IPv4" do
        let!(:first_ipv4_client) { build_stubbed(:client, ip_range: "123.123.0.1/24") }
        let!(:second_ipv4_client) { build_stubbed(:client, ip_range: "123.123.0.2/32") }
        let(:clients) { [first_ipv4_client, second_ipv4_client] }
        let(:radsec_clients) { [] }

        it "generates an authorised clients configuration file" do
          expected_config = "client #{first_ipv4_client.ip_range} {
\tipv4addr = #{first_ipv4_client.ip_range}
\tsecret = #{first_ipv4_client.shared_secret}
\tshortname = #{first_ipv4_client.site.tag}
}

client #{second_ipv4_client.ip_range} {
\tipv4addr = 123.123.0.2/32
\tsecret = #{second_ipv4_client.shared_secret}
\tshortname = #{second_ipv4_client.site.tag}
}

clients radsec {
}"
          expect(result).to eq(expected_config)
        end
      end

      context "when there are radsec clients" do
        let!(:first_ipv4_client) { build_stubbed(:client, ip_range: "123.123.0.1/24") }
        let!(:second_ipv4_client) { build_stubbed(:client, ip_range: "123.123.0.2/32") }
        let!(:first_radsec_client) { build_stubbed(:client, ip_range: "123.123.0.3/24", shared_secret: "radsec") }
        let!(:second_radsec_client) { build_stubbed(:client, ip_range: "123.123.0.4/32", shared_secret: "radsec") }
        let(:clients) { [first_ipv4_client, second_ipv4_client] }
        let(:radsec_clients) { [first_radsec_client, second_radsec_client] }

        it "generates an authorised clients configuration file" do
          expected_config = "client #{first_ipv4_client.ip_range} {
\tipv4addr = #{first_ipv4_client.ip_range}
\tsecret = #{first_ipv4_client.shared_secret}
\tshortname = #{first_ipv4_client.site.tag}
}

client #{second_ipv4_client.ip_range} {
\tipv4addr = 123.123.0.2/32
\tsecret = #{second_ipv4_client.shared_secret}
\tshortname = #{second_ipv4_client.site.tag}
}

clients radsec {
\tclient #{first_radsec_client.ip_range} {
\t\tipv4addr = 123.123.0.3/24
\t\tsecret = radsec
\t\tshortname = #{first_radsec_client.site.tag}
\t\tproto = tls
\t}

\tclient #{second_radsec_client.ip_range} {
\t\tipv4addr = 123.123.0.4/32
\t\tsecret = radsec
\t\tshortname = #{second_radsec_client.site.tag}
\t\tproto = tls
\t}\n
}"
          expect(result).to eq(expected_config)
        end
      end
    end

    describe "when there are no entries in the database" do
      let(:clients) { [] }
      let(:radsec_clients) { [] }

      it "generates an empty authorised clients configuration file" do
        expect(result).to eq("clients radsec {\n}")
      end
    end
  end
end
