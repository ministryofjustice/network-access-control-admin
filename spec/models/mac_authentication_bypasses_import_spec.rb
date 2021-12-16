require "rails_helper"

describe MacAuthenticationBypassesImport, type: :model do
  subject { described_class.new(file_contents) }

  context "valid csv entries" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer1,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;Tunnel-ID=777,102 Petty France"
    end

    it "creates valid MABs" do
      expect(subject.errors).to be_empty
    end
  end

  context "invalid csv entries" do
    let(:file_contents) do
      "Description,Responses,Site
some test,Tunnel-Type=VLAN,102 Petty France"
    end

    it "records the validation errors" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(["Bypasses Address can't be blank", "Bypasses Address is invalid"])
    end
  end
end
