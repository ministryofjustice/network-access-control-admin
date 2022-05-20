require "rails_helper"

describe UseCases::CSVImport::Policies do
  subject { described_class.new({ contents: file_contents, filename: }) }
  let(:filename) { "dummy.csv" }

  context "valid csv entries" do
    before do
      subject.call
    end

    let(:file_contents) do
      "Name,Description,Action,Rules,Responses
MOJO_LAN_VLAN101,Some description,,TLS-Cert-Common-Name=~hihi;User-Name=Bob,Tunnel-Type=VLAN;Reply-Message=Hello to you"
    end

    it "creates valid Policies" do
      saved_policy = Policy.find_by_name("MOJO_LAN_VLAN101")

      expect(saved_policy.name).to eq("MOJO_LAN_VLAN101")
      expect(saved_policy.description).to eq("Some description")
      expect(saved_policy.action).to eq("accept")

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

  context "csv with invalid header" do
    let(:file_contents) do
      "INVALID,Description,Rules,Responses
MOJO_LAN_VLAN101,Some description,,"
    end

    it "records the validation errors" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "The CSV header is invalid",
        ],
      )
    end
  end

  context "when the file is missing" do
    let(:file_contents) { nil }

    it "records the validation errors" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "CSV is missing",
        ],
      )
    end
  end

  context "when the file extention is invalid" do
    let(:file_contents) do
      "Name,Description,Rules,Responses
MOJO_LAN_VLAN101,Some description,,,"
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

  context "when there is no data to be imported" do
    let(:file_contents) do
      "Name,Description,Action,Rules,Responses"
    end

    it "records the validation errors" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "There is no data to be imported",
        ],
      )
    end
  end

  context "when policy name is already taken" do
    before do
      create(:policy, name: "MOJO_LAN_VLAN101")
    end

    let(:file_contents) do
      "Name,Description,Action,Rules,Responses
MOJO_LAN_VLAN101,Some description,,TLS-Cert-Common-Name=~hihi;User-Name=Bob,Tunnel-Type=VLAN;Reply-Message=Hello to you"
    end

    it "records the validation errors" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Error on row 2: Name has already been taken",
        ],
      )
    end
  end

  context "when there are duplicate policy names in the CSV" do
    let(:file_contents) do
      "Name,Description,Action,Rules,Responses
MOJO_LAN_VLAN101,Some description,,,
MOJO_LAN_VLAN101,Another description,,,"
    end

    it "records the validation errors" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Duplicate Policy name \"MOJO_LAN_VLAN101\" found in CSV",
        ],
      )
    end
  end

  context "csv with invalid rule attribute" do
    let(:file_contents) do
      "Name,Description,Action,Rules,Responses
MOJO_LAN_VLAN101,Some description,,Invalid-Attribute=Invalid,"
    end

    it "records the validation errors" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Error on row 2: Rules is invalid",
          "Error on row 2: Unknown attribute 'Invalid-Attribute'",
        ],
      )
    end
  end

  context "csv with invalid response attribute" do
    let(:file_contents) do
      "Name,Description,Action,Rules,Responses
MOJO_LAN_VLAN101,Some description,,,3Com-Connect_Id=ASASAS"
    end

    it "records the validation errors" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Error on row 2: Responses is invalid",
          "Error on row 2: Unknown or invalid value \"ASASAS\" for attribute 3Com-Connect_Id",
        ],
      )
    end
  end

  context "when there are duplicate attributes in the CSV" do
    let(:file_contents) do
      "Name,Description,Action,Rules,Responses
MOJO_LAN_VLAN101,Some description,,User-Name=~Bo;User-Name=Bob,Tunnel-Type=VLAN;Tunnel-Type=VLAN"
    end

    it "records the validation errors" do
      expect(subject.call.fetch(:errors)).to eq(
        [
          "Error on row 2: Duplicate attribute \"User-Name\" found in CSV",
          "Error on row 2: Duplicate attribute \"Tunnel-Type\" found in CSV",
        ],
      )
    end
  end
end
