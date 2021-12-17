require "rails_helper"

describe MacAuthenticationBypassesImport, type: :model do
  subject { described_class.new(file_contents) }

  context "valid csv entries" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer1,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777,102 Petty France"
    end

    before do
      create(:site, name: "102 Petty France")
    end

    it "creates valid MABs" do
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.records.count).to be(1)

      expected_mab = subject.records.first
      expect(expected_mab.name).to eq("Printer1")
      expect(expected_mab.address).to eq("aa-bb-cc-dd-ee-ff")
      expect(expected_mab.description).to eq("some test")
      expect(expected_mab.site.name).to eq("102 Petty France")

      expect(expected_mab.responses.first.response_attribute).to eq("Tunnel-Type")
      expect(expected_mab.responses.first.value).to eq("VLAN")
      expect(expected_mab.responses.second.response_attribute).to eq("Reply-Message")
      expect(expected_mab.responses.second.value).to eq("Hello to you")
      expect(expected_mab.responses.third.response_attribute).to eq("SG-Tunnel-Id")
      expect(expected_mab.responses.third.value).to eq("777")

      expect(subject.save).to be_truthy

      saved_bypass = MacAuthenticationBypass.last

      expect(saved_bypass.id).to_not be_nil
      saved_bypass.responses.each do |response|
        expect(response.id).to_not be_nil
      end
    end
  end

  context "invalid csv entries" do
    let(:file_contents) do
      "Description,Responses,Site
some test,Tunnel-Type=VLAN,102 Petty France"
    end

    it "records the validation errors" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Bypasses Address can't be blank",
          "Bypasses Address is invalid",
        ],
      )
    end
  end
end
