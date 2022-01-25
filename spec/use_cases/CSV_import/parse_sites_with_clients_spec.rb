require "rails_helper"

describe UseCases::CSVImport::ParseSitesWithClients do
  subject(:use_case) do
    described_class.new(file_contents)
  end

  describe "#call" do
    context "when there are file contents" do
      let(:file_contents) do
        "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1;Test Policy 2,Dlink-VLAN-ID=888;Reply-Message=hi"
      end
      let(:records) { subject.call }

      before do
        create(:policy, name: "Test Policy 1")
        create(:policy, name: "Test Policy 2")
      end

      it "parses the file contents into sites and clients records" do
        expect(records.count).to eq(1)

        expected_site = records.first

        expect(expected_site.name).to eq("Petty France")
        expect(expected_site.policies.first.name).to eq("Fallback policy for Petty France")
        expect(expected_site.policies.second.name).to eq("Test Policy 1")
        expect(expected_site.policies.last.name).to eq("Test Policy 2")

        expect(expected_site.clients.first.ip_range).to eq("128.0.0.1")
        expect(expected_site.clients.first.shared_secret).to_not be_nil
        expect(expected_site.clients.first.radsec).to be_falsey

        expect(expected_site.clients.last.ip_range).to eq("128.0.0.1")
        expect(expected_site.clients.last.shared_secret).to eq "radsec"
        expect(expected_site.clients.last.radsec).to be true

        expect(expected_site.policies.first.responses.first.response_attribute).to eq("Dlink-VLAN-ID")
        expect(expected_site.policies.first.responses.first.value).to eq("888")

        expect(expected_site.policies.first.responses.second.response_attribute).to eq("Reply-Message")
        expect(expected_site.policies.first.responses.second.value).to eq("hi")
      end

      it "creates sites and clients with valid IDs" do
        expect(records.first.clients.first.id).to eq(1)
        expect(records.last.clients.last.id).to eq(3)
      end

      it "creates fallback policy responses with valid IDs" do
        fallback_policy_id = records.first.policies.first.id

        expect(records.first.policies.first.responses.first.id).to eq(1)
        expect(records.first.policies.first.responses.first.policy_id).to eq(fallback_policy_id)
        expect(records.first.policies.first.responses.last.id).to eq(2)
        expect(records.first.policies.first.responses.last.policy_id).to eq(fallback_policy_id)
      end
    end
  end
end
