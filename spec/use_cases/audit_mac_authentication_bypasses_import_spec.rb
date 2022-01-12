require "rails_helper"

describe UseCases::AuditMacAuthenticationBypassesImport do
  subject(:use_case) do
    described_class.new(user)
  end

  describe "#call" do
    let!(:user) { build_stubbed(:user) }

    context "when there are imported records" do
      let!(:first_mab) { create(:mac_authentication_bypass, address: "aa-bb-cc-dd-ee-ff") }
      let!(:second_mab) { create(:mac_authentication_bypass, address: "bb-bb-cc-dd-ee-ff") }
      let!(:first_mab_response) { create(:mab_response, mac_authentication_bypass: first_mab, response_attribute: "Tunnel-Type", value: "VLAN") }
      let!(:second_mab_response) { create(:mab_response, mac_authentication_bypass: first_mab, response_attribute: "Reply-Message", value: "Hello") }

      it "audits the imported MABs" do
        expect(use_case.call([first_mab, second_mab])).to be_truthy

        first_audited_mab = Audit.all[-4]
        first_audited_mab_response = Audit.all[-3]
        second_audited_mab_response = Audit.all[-2]
        second_audited_mab = Audit.last

        expect(first_audited_mab.auditable_type).to eq("MacAuthenticationBypass")
        expect(first_audited_mab.audited_changes).to eq({
          "address" => first_mab.address,
          "description" => first_mab.description,
          "name" => first_mab.name,
          "site_id" => first_mab.site_id,
        })

        expect(second_audited_mab.auditable_type).to eq("MacAuthenticationBypass")
        expect(second_audited_mab.audited_changes).to eq({
          "address" => second_mab.address,
          "description" => second_mab.description,
          "name" => second_mab.name,
          "site_id" => second_mab.site_id,
        })

        expect(first_audited_mab_response.auditable_type).to eq("Response")
        expect(first_audited_mab_response.audited_changes).to eq({
          "mac_authentication_bypass_id" => first_mab.id,
          "response_attribute" => first_mab_response.response_attribute,
          "value" => first_mab_response.value,
        })
        expect(second_audited_mab_response.auditable_type).to eq("Response")
        expect(second_audited_mab_response.audited_changes).to eq({
          "mac_authentication_bypass_id" => first_mab.id,
          "response_attribute" => second_mab_response.response_attribute,
          "value" => second_mab_response.value,
        })
      end
    end
  end
end
