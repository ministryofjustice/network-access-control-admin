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
      let(:records) { subject.call[:records] }

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
    end

    context "when optional data is not provided" do
      let(:file_contents) do
        "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy
Petty France,,,,"
      end

      let(:parse_sites_with_clients) { UseCases::CSVImport::ParseSitesWithClients.new(file_contents) }
      let(:records) { subject.call[:records] }

      it "creates a valid site with a fallback policy" do
        expect(subject.call[:errors]).to be_empty
        expect(records.first.name).to eq("Petty France")
        expect(records.first.policies.first.name).to eq("Fallback policy for Petty France")
      end
    end

    context "when the CSV header is invalid" do
      let(:file_contents) do
        "Site NameInvalid
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1;Test Policy 2,Dlink-VLAN-ID=888;Reply-Message=hi"
      end

      it "returns a header validation error" do
        expect(subject.call[:errors]).to eq(["The CSV header is invalid"])
      end
    end

    context "csv with no content but headers" do
      let(:file_contents) do
        "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy"
      end

      it "returns a validation error" do
        expect(subject.call[:errors]).to eq(["There is no data to be imported"])
      end
    end

    context "csv is not attached" do
      let(:file_contents) { nil }

      it "returns a validation error" do
        expect(subject.call[:errors]).to eq(["CSV is missing"])
      end
    end

    context "csv with unknown policies" do
      let(:file_contents) do
        "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Unknown 1;Unknown 2,Dlink-VLAN-ID=888;Reply-Message=hi"
      end

      it "returns a validation error" do
        expect(subject.call[:errors]).to eq(["Error on row 2: Policy Unknown 1 is not found", "Error on row 2: Policy Unknown 2 is not found"])
      end
    end
  end
end
