require "rails_helper"

describe UseCases::GenerateAuthorisedMacs do
  subject(:result) do
    described_class.new.call(mac_authentication_bypasses:)
  end

  let(:site) { create(:site, name: "Test Site") }

  describe "#call" do
    describe "when there are entries in the database" do
      let!(:mac_authentication_bypasses) { MacAuthenticationBypass.all }

      context "when there are no MAB responses" do
        before do
          create(:mac_authentication_bypass, address: "aa-11-22-33-44-55", site:)
          create(:mac_authentication_bypass, address: "ff-99-88-77-66-55", site:)
        end

        it "generates a authorised_macs configuration file" do
          expected_config = %(aa-11-22-33-44-55.test_site Cleartext-Password := aa1122334455\n\nff-99-88-77-66-55.test_site Cleartext-Password := ff9988776655\n)

          expect(result).to eq(expected_config)
        end
      end

      context "when there are MAB responses" do
        let!(:mac_authentication_bypass) { create(:mac_authentication_bypass, address: "aa-66-77-88-99-00", site:) }
        let!(:second_mac_authentication_bypass) { create(:mac_authentication_bypass, address: "bb-cc-00-11-22-33", site:) }

        before do
          create(:mab_response, mac_authentication_bypass:, response_attribute: "Tunnel-Medium-Type", value: "IEEE-802")
          create(:mab_response, mac_authentication_bypass:, response_attribute: "Tunnel-Private-Group-Id", value: "123456")

          create(:mab_response, mac_authentication_bypass: second_mac_authentication_bypass, response_attribute: "Tunnel-Medium-Type", value: "IEEE-802")
          create(:mab_response, mac_authentication_bypass: second_mac_authentication_bypass, response_attribute: "Tunnel-Private-Group-Id", value: "123456")
        end

        it "generates an authorised_macs configuration file" do
          expected_config = %(aa-66-77-88-99-00.test_site Cleartext-Password := aa6677889900
        Tunnel-Medium-Type = "IEEE-802",
        Tunnel-Private-Group-Id = "123456"

bb-cc-00-11-22-33.test_site Cleartext-Password := bbcc00112233
        Tunnel-Medium-Type = "IEEE-802",
        Tunnel-Private-Group-Id = "123456"
)

          expect(result).to eq(expected_config)
        end
      end
    end

    describe "when there are no entries in the database" do
      let(:mac_authentication_bypasses) { [] }

      it "generates an empty authorised_clients configuration file" do
        expect(result).to eq("\n")
      end
    end
  end
end
