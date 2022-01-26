require "rails_helper"

describe CSVImport::SitesWithClients, type: :model do
  subject { described_class.new(parse_sites_with_clients) }

  context "valid csv entries" do
    let(:file_contents) do
      "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1;Test Policy 2,Dlink-VLAN-ID=888;Reply-Message=hi"
    end

    let(:parse_sites_with_clients) { UseCases::CSVImport::ParseSitesWithClients.new(file_contents) }

    before do
      create(:policy, name: "Test Policy 1")
      create(:policy, name: "Test Policy 2")
    end

    it "creates valid sites and clients" do
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.records.count).to be(1)

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
  end

  context "when CSV parser return errors" do
    let(:file_contents) { "INVALID" }
    let(:parse_sites_with_clients) { instance_double(UseCases::CSVImport::ParseSitesWithClients) }

    before do
      allow(parse_sites_with_clients).to receive(:call).and_return({ errors: ["Some CSV parse error"] })
    end

    it "records the validation errors" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Some CSV parse error",
        ],
      )
    end
  end

  context "when a site already exists" do
    let(:file_contents) do
      "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1,Dlink-VLAN-ID=888;Reply-Message=hi"
    end

    let(:parse_sites_with_clients) { UseCases::CSVImport::ParseSitesWithClients.new(file_contents) }

    before do
      create(:site, name: "Petty France")
      create(:policy, name: "Test Policy 1")
    end

    it "show a validation error" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Error on row 2: Site Name has already been taken",
          "Error on row 2: Site Policies is invalid",
          "Error on row 2: Fallback Policy Name has already been taken",
        ],
      )
    end
  end

  context "when there are duplicate site records" do
    let(:file_contents) do
      "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy
Petty France,,,,
Petty France,,,,"
    end

    let(:parse_sites_with_clients) { UseCases::CSVImport::ParseSitesWithClients.new(file_contents) }

    it "show a validation error" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Error on row 3: Site Name has already been taken",
        ],
      )
    end
  end

  context "when a client ip range has already been taken" do
    let(:file_contents) do
      "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1,Dlink-VLAN-ID=888;Reply-Message=hi"
    end

    let(:parse_sites_with_clients) { UseCases::CSVImport::ParseSitesWithClients.new(file_contents) }

    before do
      create(:client, ip_range: "128.0.0.1", site: create(:site, name: "Some Site Name"))
      create(:policy, name: "Test Policy 1")
    end

    it "show a validation error" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Error on row 2: Site Clients is invalid",
          "Error on row 2: Client Ip range has already been taken",
        ],
      )
    end
  end

  context "when a client ip range overlaps" do
    let(:file_contents) do
      "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1,Dlink-VLAN-ID=888;Reply-Message=hi"
    end

    let(:parse_sites_with_clients) { UseCases::CSVImport::ParseSitesWithClients.new(file_contents) }

    before do
      create(:client, ip_range: "128.0.0.1/16", site: create(:site, name: "Some Site Name"))
      create(:policy, name: "Test Policy 1")
    end

    it "show a validation error" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Error on row 2: Site Clients is invalid",
          "Error on row 2: Client Ip range IP overlaps with Some Site Name - 128.0.0.1/16",
        ],
      )
    end
  end

  context "when a fallback policy response is invalid" do
    let(:file_contents) do
      "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy
  Petty France,,,,Invalid-Attribute=888"
    end

    let(:parse_sites_with_clients) { UseCases::CSVImport::ParseSitesWithClients.new(file_contents) }

    it "show a validation error" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Error on row 2: Site Policies is invalid",
          "Error on row 2: Fallback Policy Responses is invalid",
          "Error on row 2: Unknown attribute 'Invalid-Attribute'",
        ],
      )
    end
  end
end
