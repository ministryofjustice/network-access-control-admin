require "rails_helper"

describe UseCases::CSVImport::MacAuthenticationBypasses do
  subject { described_class.new(file_contents) }

  context "valid csv entries" do
    before do
      create(:site, name: "102 Petty France")
      subject.save
    end

    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer1,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777,102 Petty France
bb-bb-cc-dd-ee-ff,Printer2,some test,,102 Petty France
cc-bb-cc-dd-ee-ff,Printer3,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777"
    end

    it "creates valid MABs" do
      result = MacAuthenticationBypass.find_by_name("Printer1")
      expect(result.address).to eq("aa-bb-cc-dd-ee-ff")
      expect(result.description).to eq("some test")
      expect(result.site.name).to eq("102 Petty France")

      expect(result.responses.first.response_attribute).to eq("Tunnel-Type")
      expect(result.responses.first.value).to eq("VLAN")
      expect(result.responses.second.response_attribute).to eq("Reply-Message")
      expect(result.responses.second.value).to eq("Hello to you")
      expect(result.responses.third.response_attribute).to eq("SG-Tunnel-Id")
      expect(result.responses.third.value).to eq("777")
    end
  end

  context "valid csv entries with no responses" do
    before { subject.save }

    let(:file_contents) do
      "Address,Name,Description,Responses,Site
bb-bb-cc-dd-ee-ff,Printer2,some test,,"
    end

    it "creates valid MABs" do
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
    before { subject.save }
    let(:file_contents) do
      "Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer1,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777,102 Petty France"
    end

    it "records the validation errors" do
      expect(subject.errors).to eq(
        [
          "The CSV header is invalid",
        ],
      )
    end
  end

  context "csv with empty list of attributes" do
    before { subject.save }
    let(:file_contents) do
      "Address,Name,Description,Responses,Site"
    end

    it "records the validation errors" do
      expect(subject.errors).to eq(
        [
          "There is no data to be imported",
        ],
      )
    end
  end

  context "csv with empty lines" do
    before { subject.save }
    let(:file_contents) do
      "Address,Name,Description,Responses,Site

aa-bb-cc-dd-ee-ff,Printer1,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777,

aa-bb-cc-11-22-33,Printer2,some test,Tunnel-Type=VLAN;Reply-Message=Bye to you;SG-Tunnel-Id=888,"
    end

    it "records the validation errors" do
      expect(subject.errors).to be_empty
      expect(MacAuthenticationBypass.all.count).to eq(2)
    end
  end

  context "csv with invalid MAC address and unknown site" do
    before { subject.save }
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ffff,Printer3,some test3,Tunnel-Type=VLAN;3Com-Connect_Id=1212,Unknown Site"
    end

    it "records the validation errors" do
      expect(subject.errors).to eq(
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
    before { subject.save }
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer3,some test3,Tunnel-Type=VLAN;3Com-Connect_Id=ASASAS,"
    end

    it "records the validation errors" do
      expect(subject.errors).to eq(
        [
          "Error on row 2: Responses is invalid",
          "Error on row 2: Unknown or invalid value \"ASASAS\" for attribute 3Com-Connect_Id",
        ],
      )
    end
  end

  context "when a MAC address already exist" do
    before do
      create(:mac_authentication_bypass, name: "duplicate-mac", address: "aa-bb-cc-dd-ee-cc")
      subject.save
    end

    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-cc,Printer1,some test,SG-Tunnel-Id=777"
    end

    it "records the validation errors" do
      expect(subject.errors).to eq(
        [
          "Error on row 2: Address has already been taken",
        ],
      )
    end
  end
end
