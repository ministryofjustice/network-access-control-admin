require "rails_helper"

describe UseCases::CSVImport::SitesWithClients do
  subject { described_class.new({ contents: file_contents, filename: }) }
  let(:filename) { "dummy.csv" }

  context "valid csv entries" do
    before do
      create(:policy, name: "Test Policy 1")
      create(:policy, name: "Test Policy 2")
      subject.call
    end

    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1;Test Policy 2,Dlink-VLAN-ID=888;Reply-Message=hi"
    end

    it "creates valid sites and clients" do
      result = Site.find_by_name("Petty France")
      expect(result.id).to_not be_nil
      expect(result.tag).to eq("petty_france")

      expect(result.policies.count).to eq(3)
      expect(result.policy_count).to eq(result.policies.count)

      expect(result.fallback_policy.name).to eq("Fallback policy for Petty France")
      expect(result.fallback_policy.responses.first.response_attribute).to eq("Dlink-VLAN-ID")
      expect(result.fallback_policy.responses.first.value).to eq("888")
      expect(result.fallback_policy.responses.second.response_attribute).to eq("Reply-Message")
      expect(result.fallback_policy.responses.second.value).to eq("hi")

      expect(result.policies.first.name).to eq("Test Policy 1")
      expect(result.site_policy.second.priority).to eq(0)
      expect(result.policies.second.name).to eq("Test Policy 2")
      expect(result.site_policy.third.priority).to eq(10)
      expect(result.policies.third.name).to eq("Fallback policy for Petty France")

      expect(result.clients.first.radsec).to be_falsey
      expect(result.clients.first.ip_range).to eq("128.0.0.1/32")
      expect(result.clients.second.radsec).to be_falsey
      expect(result.clients.second.ip_range).to eq("10.0.0.1/32")
      expect(result.clients.last.radsec).to be_truthy
      expect(result.clients.last.ip_range).to eq("128.0.0.1/32")

      result.clients.each do |client|
        expect(client.id).to_not be_nil
      end
    end
  end

  context "valid csv entries without clients or policies" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
Petty France,,,,Dlink-VLAN-ID=888;Reply-Message=hi"
    end

    before do
      subject.call
    end

    it "creates valid sites and fallback policies" do
      saved_site = Site.find_by_name("Petty France")

      expect(saved_site.id).to_not be_nil
      expect(saved_site.tag).to eq("petty_france")
      expect(saved_site.clients).to be_empty

      expect(saved_site.policy_count).to eq(1)
      expect(saved_site.fallback_policy.name).to eq("Fallback policy for Petty France")
      expect(saved_site.fallback_policy.responses.first.response_attribute).to eq("Dlink-VLAN-ID")
      expect(saved_site.fallback_policy.responses.first.value).to eq("888")
      expect(saved_site.fallback_policy.responses.second.response_attribute).to eq("Reply-Message")
      expect(saved_site.fallback_policy.responses.second.value).to eq("hi")
    end
  end

  context "valid csv entries without fallback policy responses" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
Petty France,128.0.0.1,,,"
    end

    before do
      subject.call
    end

    it "creates valid sites with default reject fallback policy" do
      saved_site = Site.find_by_name("Petty France")

      expect(saved_site.id).to_not be_nil
      expect(saved_site.tag).to eq("petty_france")
      expect(saved_site.clients.count).to be(1)

      expect(saved_site.policy_count).to eq(1)
      expect(saved_site.fallback_policy.name).to eq("Fallback policy for Petty France")
      expect(saved_site.fallback_policy.responses.first.response_attribute).to eq("Post-Auth-Type")
      expect(saved_site.fallback_policy.responses.first.value).to eq("Reject")
    end
  end

  context "csv with invalid header" do
    let(:file_contents) { "INVALID HEADER" }

    it "records the validation errors" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "The CSV header is invalid",
        ],
      )
    end
  end

  context "when the file extention is invalid" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
Petty France,128.0.0.1,,,"
    end
    let(:filename) { "inva.lid" }

    it "records the validation errors" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "The file extension is invalid",
        ],
      )
    end
  end

  context "when a site already exists" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1,Dlink-VLAN-ID=888;Reply-Message=hi"
    end

    before do
      create(:site, name: "Petty France")
      create(:policy, name: "Test Policy 1")
    end

    it "show a validation error" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Error on row 2: Site Name has already been taken",
          "Error on row 2: Site Policies is invalid",
          "Error on row 2: Fallback Policy Name has already been taken",
        ],
      )
    end
  end

  context "when a client ip range has already been taken" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1,Dlink-VLAN-ID=888;Reply-Message=hi"
    end

    before do
      create(:client, ip_range: "128.0.0.1", site: create(:site, name: "Some Site Name"))
      create(:policy, name: "Test Policy 1")
    end

    it "show a validation error" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Error on row 2: Site Clients is invalid",
          "Error on row 2: Client Ip range has already been taken",
        ],
      )
    end
  end

  context "when a client ip range overlaps" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
Petty France,128.0.0.1;10.0.0.1/32,128.0.0.1,Test Policy 1,Dlink-VLAN-ID=888;Reply-Message=hi"
    end

    before do
      create(:client, ip_range: "128.0.0.1/16", site: create(:site, name: "Some Site Name"))
      create(:policy, name: "Test Policy 1")
    end

    it "show a validation error" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Error on row 2: Site Clients is invalid",
          "Error on row 2: Client Ip range IP overlaps with Some Site Name - 128.0.0.1/16",
        ],
      )
    end
  end

  context "when a fallback policy response is invalid" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
  Petty France,,,,Invalid-Attribute=888"
    end

    it "show a validation error" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Error on row 2: Site Policies is invalid",
          "Error on row 2: Fallback Policy Responses is invalid",
          "Error on row 2: Unknown attribute 'Invalid-Attribute'",
        ],
      )
    end
  end

  context "when there are duplicate site records in CSV" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
Petty France,,,,
Petty France,,,,"
    end

    it "show a validation error" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Duplicate Site name \"Petty France\" found in CSV",
        ],
      )
    end
  end

  context "when there are duplicate RADIUS client ip ranges in CSV" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
First Site,128.0.0.1,128.0.0.1,,
Site with same IP twice,128.0.0.2;128.0.0.2,128.0.0.3,,
Site with duplicate ip,128.0.0.1,128.0.0.4,,"
    end

    it "show a validation error" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Overlapping RADIUS Clients IP ranges \"128.0.0.1\" - \"128.0.0.1\" found in CSV",
          "Overlapping RADIUS Clients IP ranges \"128.0.0.2\" - \"128.0.0.2\" found in CSV",
        ],
      )
    end
  end

  context "when there are duplicate RadSec client ip ranges in CSV" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
First Site,128.0.0.1,128.0.0.1,,
Site with same IP twice,128.0.0.2,128.0.0.2;128.0.0.2,,
Site with duplicate ip,128.0.0.3,128.0.0.1,,"
    end

    it "show a validation error" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Overlapping RadSec Clients IP ranges \"128.0.0.1\" - \"128.0.0.1\" found in CSV",
          "Overlapping RadSec Clients IP ranges \"128.0.0.2\" - \"128.0.0.2\" found in CSV",
        ],
      )
    end
  end

  context "when there are duplicate response attributes in CSV" do
    let(:file_contents) do
      "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses
Petty France,128.0.0.1,128.0.0.1,,Dlink-VLAN-ID=888;Dlink-VLAN-ID=777
Another Site,123.0.0.1,123.0.0.1,,Dlink-VLAN-ID=888;Dlink-VLAN-ID=777"
    end

    it "show a validation error" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Error on row 2: Duplicate attribute \"Dlink-VLAN-ID\" found in CSV",
          "Error on row 3: Duplicate attribute \"Dlink-VLAN-ID\" found in CSV",
        ],
      )
    end
  end
end
