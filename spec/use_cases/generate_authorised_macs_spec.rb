require "rails_helper"

describe UseCases::GenerateAuthorisedMacs do
  subject(:result) do
    described_class.new.call(mac_authentication_bypasses: mac_authentication_bypasses)
  end

  describe "#call" do
    describe "When there are entries in the database" do
      before do
        create(:mac_authentication_bypass, address: "aa-11-22-33-44-55")
        create(:mac_authentication_bypass, address: "ff-99-88-77-66-55")
      end

      let(:mac_authentication_bypasses) { MacAuthenticationBypass.all }

      it "generates a authorised_clients configuration file" do
        expected_config = %(aa-11-22-33-44-55
ff-99-88-77-66-55)

        expect(result).to eq(expected_config)
      end
    end

    describe "When there are no entries in the database" do
      let(:mac_authentication_bypasses) { [] }

      it "generates an empty authorised_clients configuration file" do
        expect(result).to eq("")
      end
    end
  end
end
