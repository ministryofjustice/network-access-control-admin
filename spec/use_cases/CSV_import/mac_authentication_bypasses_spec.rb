require "rails_helper"

describe UseCases::CSVImport::MacAuthenticationBypasses do
  subject { described_class.new({ contents: file_contents, filename: }) }
  let(:filename) { "dummy.csv" }

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

  context "valid csv with empty lines" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site

aa-bb-cc-dd-ee-ff,Printer1,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777,

aa-bb-cc-11-22-33,Printer2,some test,Tunnel-Type=VLAN;Reply-Message=Bye to you;SG-Tunnel-Id=888,"
    end

    it "ignores blank lines in a CSV" do
      expect(subject.save).to eq({ errors: [] })
      expect(MacAuthenticationBypass.all.count).to eq(2)
    end
  end

  context "csv with invalid header" do
    let(:file_contents) do
      "Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer1,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;SG-Tunnel-Id=777,102 Petty France"
    end

    it "records the validation errors" do
      expect(subject.save.fetch(:errors)).to eq(
        [
          "The CSV header is invalid",
        ],
      )
    end
  end

  context "when the file extention is invalid" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer1,some test,,"
    end
    let(:filename) { "inva.lid" }

    it "records the validation errors" do
      expect(subject.save.fetch(:errors)).to eq(
        [
          "The file extension is invalid",
        ],
      )
    end
  end

  context "csv with empty list of attributes" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site"
    end

    it "records the validation errors" do
      expect(subject.save.fetch(:errors)).to eq(
        [
          "There is no data to be imported",
        ],
      )
    end
  end

  context "csv with invalid MAC address and unknown site" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ffff,Printer3,some test3,Tunnel-Type=VLAN;3Com-Connect_Id=1212,Unknown Site"
    end

    it "records the validation errors" do
      expect(subject.save.fetch(:errors)).to eq(
        [
          "Error on row 2: Address is invalid",
          "Site \"Unknown Site\" is not found",
        ],
      )
    end
  end

  context "csv with invalid response attribute" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer3,some test3,Tunnel-Type=VLAN;3Com-Connect_Id=ASASAS,"
    end

    it "records the validation errors" do
      expect(subject.save.fetch(:errors)).to eq(
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
    end

    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-cc,Printer1,some test,SG-Tunnel-Id=777"
    end

    it "records the validation errors" do
      expect(subject.save.fetch(:errors)).to eq(
        [
          "Error on row 2: Address has already been taken",
        ],
      )
    end
  end

  context "when there are duplicate MAC addresses in the CSV" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-cc,Printer1,some test,SG-Tunnel-Id=777
aa-bb-cc-dd-ee-cc,Printer2,some test2,SG-Tunnel-Id=888"
    end

    it "records the validation errors" do
      expect(subject.save.fetch(:errors)).to eq(
        [
          "Duplicate MAC address aa-bb-cc-dd-ee-cc found in CSV",
        ],
      )
    end
  end

  context "when there are duplicate response attributes in CSV" do
    let(:file_contents) do
      "Address,Name,Description,Responses,Site
aa-bb-cc-dd-ee-ff,Printer1,some test,Reply-Message=Hello to you;Reply-Message=Hello to you,
cc-bb-cc-dd-ee-ff,Printer3,some test,Reply-Message=Hello to you;Reply-Message=Hello to you,"
    end

    it "show a validation error" do
      expect(subject.save.fetch(:errors)).to eq(
        [
          "Error on row 1: Duplicate response attribute \"Reply-Message\" found in CSV",
          "Error on row 2: Duplicate response attribute \"Reply-Message\" found in CSV",
        ],
      )
    end
  end
end
