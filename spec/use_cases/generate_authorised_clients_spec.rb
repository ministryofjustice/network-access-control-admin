require "rails_helper"

describe UseCases::GenerateAuthorisedClients do
	subject(:result) do
		described_class.new.call(clients: clients)
	end

	describe "#call" do
		describe "when there are entries in the database" do
			let(:first_client) { create(:client, ip_range: "123.123.0.1/24") }
			let(:second_client) { create(:client, ip_range: "123.123.0.2/32") }
			let(:clients) { Client.all }

			it "generates a authorised_clients configuration file" do
				expected_config = "client #{first_client.tag.sub(" ", "_").downcase} {
\tipv4addr = 123.123.0.1/24
\tsecret = #{first_client.shared_secret}
}

client #{second_client.tag.sub(" ", "_").downcase} {
\tipv4addr = 123.123.0.2/32
\tsecret = #{second_client.shared_secret}
}"

				expect(result).to include(expected_config)
			end
		end

		describe "when there are no entries in the database" do
		  let(:clients) { [] }

		  it "generates an empty authorised_clients configuration file" do
		    expect(result).to eq("")
		  end
		end
	end
end
