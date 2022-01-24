require "rails_helper"

describe CSVImport::SitesWithClients, type: :model do
  subject { described_class.new(file_contents) }

  context "valid csv entries" do
    let(:file_contents) do
      "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1;Test Policy 2,Dlink-VLAN-ID=888;Reply-Message=hi"
    end

    before do
      create(:policy, name: "Test Policy 1")
      create(:policy, name: "Test Policy 2")
    end

    it "creates valid sites and clients" do
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.records.count).to be(1)

      expected_site = subject.records.first
      expect(expected_site.name).to eq("Petty France")
      expect(expected_site.policies.first.name).to eq("Fallback policy for Petty France")
      expect(expected_site.policies.second.name).to eq("Test Policy 1")
      expect(expected_site.policies.last.name).to eq("Test Policy 2")

      expect(expected_site.clients.first.ip_range).to eq("128.0.0.1")
      expect(expected_site.clients.first.shared_secret).to_not be_nil
      expect(expected_site.clients.first.radsec).to be_falsey

      expect(expected_site.clients.last.ip_range).to eq("128.0.0.1")
      expect(expected_site.clients.last.shared_secret).to_not be_nil
      expect(expected_site.clients.last.radsec).to be true

      expect(expected_site.policies.first.responses.first.response_attribute).to eq("Dlink-VLAN-ID")
      expect(expected_site.policies.first.responses.first.value).to eq("888")

      expect(expected_site.policies.first.responses.second.response_attribute).to eq("Reply-Message")
      expect(expected_site.policies.first.responses.second.value).to eq("hi")

      expect(subject.save).to be_truthy

      saved_site = Site.last

      expect(saved_site.id).to_not be_nil
      expect(saved_site.tag).to eq("petty_france")
      expect(saved_site.clients.first.ip_range).to eq("128.0.0.1/32")
      expect(saved_site.clients.last.ip_range).to eq("128.0.0.1/32")

      expect(saved_site.policy_count).to eq(3)
      expect(saved_site.fallback_policy.name).to eq("Fallback policy for Petty France")
      expect(saved_site.fallback_policy.responses.first.response_attribute).to eq("Dlink-VLAN-ID")
      expect(saved_site.fallback_policy.responses.first.value).to eq("888")
      expect(saved_site.fallback_policy.responses.second.response_attribute).to eq("Reply-Message")
      expect(saved_site.fallback_policy.responses.second.value).to eq("hi")

      saved_site.clients.each do |client|
        expect(client.id).to_not be_nil
      end
    end

    it "creates sites and clients with valid IDs" do
      expect(subject.records.first.clients.first.id).to eq(1)
      expect(subject.records.last.clients.last.id).to eq(3)
    end
  end
end
