require "rails_helper"

describe UseCases::CSVImport::Policies do
  subject { described_class.new({ contents: file_contents, filename: "dummy.csv" }) }

  context "valid csv entries" do
    before do
      subject.save
    end

    let(:file_contents) do
      "Name,Description,Rules,Responses
MOJO_LAN_VLAN101,Some description,TLS-Cert-Common-Name=~hihi;User-Name=Bob,Tunnel-Type=VLAN;Reply-Message=Hello to you"
    end

    it "creates valid Policies" do
      saved_policy = Policy.find_by_name("MOJO_LAN_VLAN101")

      expect(saved_policy.name).to eq("MOJO_LAN_VLAN101")
      expect(saved_policy.description).to eq("Some description")

      expect(saved_policy.rules.first.request_attribute).to eq("TLS-Cert-Common-Name")
      expect(saved_policy.rules.first.operator).to eq("contains")
      expect(saved_policy.rules.first.value).to eq("hihi")
      expect(saved_policy.rules.second.request_attribute).to eq("User-Name")
      expect(saved_policy.rules.second.operator).to eq("equals")
      expect(saved_policy.rules.second.value).to eq("Bob")

      expect(saved_policy.responses.first.response_attribute).to eq("Tunnel-Type")
      expect(saved_policy.responses.first.value).to eq("VLAN")
      expect(saved_policy.responses.second.response_attribute).to eq("Reply-Message")
      expect(saved_policy.responses.second.value).to eq("Hello to you")
    end
  end
end
