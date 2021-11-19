require "rails_helper"
require "ostruct"

describe UseCases::FetchRadiusAttributes do
  subject(:use_case) do
    described_class.new(
      gateway: s3_gateway,
      output: output,
    )
  end

  let(:s3_gateway) { double(Gateways::S3) }
  let(:output) { "tmp/dictionaries" }

  before do
    FileUtils.cp_r("#{__dir__}/example_dictionaries/.", output)
  end

  context "when there are files" do
    let(:files) do
      [
        OpenStruct.new(key: "first.attributes"),
        OpenStruct.new(key: "second.attributes"),
      ]
    end

    let(:list_objects_response) { OpenStruct.new(contents: files) }

    before do
      allow(s3_gateway).to receive(:list_object_keys).and_return(list_objects_response)
      allow(s3_gateway).to receive(:read).with("first.attributes", "#{output}first.attributes").and_return("200 SUCCESS")
      allow(s3_gateway).to receive(:read).with("second.attributes", "#{output}second.attributes").and_return("200 SUCCESS")

      use_case.call
    end

    it "writes the attributes to the output file" do
      expect(s3_gateway).to have_received(:list_object_keys)
      expect(s3_gateway).to have_received(:read).twice
    end

    context "when dictionaries exist" do
      it "returns attributes" do
        expected_result = %w[Aruba-User-Role Aruba-User-Vlan Cisco-AVPair Cisco-NAS-Port]
        expect(subject.call).to eq(expected_result)
      end
    end
  end
end
