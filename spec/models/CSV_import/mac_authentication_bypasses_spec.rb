require "rails_helper"

describe CSVImport::MacAuthenticationBypasses, type: :model do
  subject { described_class.new(file_contents) }

  context "valid csv entries" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer1,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777,102 Petty France
bb-bb-cc-dd-ee-ff,Printer2,some test,,102 Petty France
cc-bb-cc-dd-ee-ff,Printer3,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777"
    end

    before do
      create(:site, name: "102 Petty France")
    end

    it "creates valid MABs" do
      expect(subject).to be_valid
      expect(subject.errors).to be_empty
      expect(subject.records.count).to be(3)

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

  context "valid csv entries with no responses" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
bb-bb-cc-dd-ee-ff,Printer2,some test,,"
    end

    it "creates valid MABs" do
      expect(subject).to be_valid
      expect(subject.errors).to be_empty

      expect(subject.save).to be_truthy
      saved_bypass = MacAuthenticationBypass.last
      expect(saved_bypass.id).to_not be_nil

      saved_bypass.responses.each do |response|
        expect(response.id).to be_nil
      end
    end
  end

  context "csv with invalid header" do
    let(:file_contents) do
      "Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer1,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777,102 Petty France"
    end

    it "records the validation errors" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "The CSV header is invalid",
        ],
      )
    end
  end

  context "csv with empty list of attributes" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site"
    end

    it "records the validation errors" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "There is no data to be imported",
        ],
      )
    end
  end

  context "csv with invalid content" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site

aa-bb-cc-dd-ee-ff,Printer1,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777,"
    end

    it "records the validation errors" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Error on row 2: Address can't be blank",
          "Error on row 2: Address is invalid",
        ],
      )
    end
  end

  context "csv with invalid MAC address and unknown site" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ffff,Printer3,some test3,Tunnel-Type=VLAN;3Com-Connect_Id=ASASAS,Unknown Site"
    end

    it "records the validation errors" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Error on row 2: Address is invalid",
          "Site \"Unknown Site\" is not found",
        ],
      )
    end

    it "does not save the records" do
      expect(subject.save).to be_falsey
    end
  end

  context "csv with invalid response attribute" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer3,some test3,Tunnel-Type=VLAN;3Com-Connect_Id=ASASAS,"
    end

    it "records the validation errors" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Error on row 2: Unknown or invalid value \"ASASAS\" for attribute 3Com-Connect_Id",
        ],
      )
    end
  end

  context "when a MAC address already exist" do
    before do
      create(:mac_authentication_bypass, address: "aa-bb-cc-dd-ee-ff")
    end

    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer1,some test,SG-Tunnel-Id=777"
    end

    it "records the validation errors" do
      expect(subject).to_not be_valid
      expect(subject.errors.full_messages).to eq(
        [
          "Error on row 2: Address has already taken",
        ],
      )
    end
  end
end
