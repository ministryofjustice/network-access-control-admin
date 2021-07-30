require "rails_helper"

describe UseCases::GenerateAuthorisedClients do
	subject(:result) do
		described_class.new.call(clients: clients)
	end

	describe "#call" do
		describe "when there are entries in the database" do
      context "and the IP ranges are IPv4" do
			let!(:first_ipv4_client) { create(:client, ip_range: "123.123.0.1/24") }
			let!(:second_ipv4_client) { create(:client, ip_range: "123.123.0.2/32") }
			let(:clients) { Client.all }

        it "generates an authorised clients configuration file" do
          expected_config = "client #{first_ipv4_client.tag.sub(" ", "_").downcase} {
\tipv4addr = 123.123.0.1/24
\tsecret = #{first_ipv4_client.shared_secret}
}

client #{second_ipv4_client.tag.sub(" ", "_").downcase} {
\tipv4addr = 123.123.0.2/32
\tsecret = #{second_ipv4_client.shared_secret}
}"

          expect(result).to eq(expected_config)
        end
      end

      context "and the IP ranges are IPv6" do
			  let!(:first_ipv6_client) { create(:client, ip_range: "2001:0db8:85a3:0000:0000:8a2e:0370:7334/32") }
			  let!(:second_ipv6_client) { create(:client, ip_range: "2002::1/128") }
  			let(:clients) { Client.all }

        it "generates an authorised clients configuration file" do
          expected_config = "client #{first_ipv6_client.tag.sub(" ", "_").downcase} {
\tipv6addr = 2001:0db8:85a3:0000:0000:8a2e:0370:7334/32
\tsecret = #{first_ipv6_client.shared_secret}
}

client #{second_ipv6_client.tag.sub(" ", "_").downcase} {
\tipv6addr = 2002::1/128
\tsecret = #{second_ipv6_client.shared_secret}
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
