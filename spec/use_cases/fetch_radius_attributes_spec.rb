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
  let(:output) { "tmp/attributes.json" }

  context "where there is one file" do
    let(:content) { File.read("spec/use_cases/attributes.vendor") }
    let(:files) { [OpenStruct.new(key: "attributes.vendor")] }
    let(:list_objects_response) { OpenStruct.new(contents: files) }

    before do
      allow(s3_gateway).to receive(:read).and_return(content)
      allow(s3_gateway).to receive(:list_object_keys).and_return(list_objects_response)

      use_case.call
    end

    it "writes the attributes to the output file" do
      expect(s3_gateway).to have_received(:list_object_keys)
      expect(s3_gateway).to have_received(:read)

      output_file_content = File.read(output)

      expected_content = <<~ATTRIBUTES
        3GPP2-Ike-Preshared-Secret-Request
        3GPP2-Security-Level
        3GPP2-Pre-Shared-Secret
        3GPP2-Reverse-Tunnel-Spec
        3GPP2-Diffserv-Class-Option
      ATTRIBUTES

      expect(output_file_content).to eq(expected_content)
    end
  end

  context "when there are multiple files" do
    let(:files) do
      [
        OpenStruct.new(key: "first.attributes"),
        OpenStruct.new(key: "second.attributes"),
      ]
    end

    let(:list_objects_response) { OpenStruct.new(contents: files) }

    before do
      allow(s3_gateway).to receive(:list_object_keys).and_return(list_objects_response)
      allow(s3_gateway).to receive(:read).with("first.attributes").and_return("ATTRIBUTE First-Attribute\nATTRIBUTE Second-Attribute")
      allow(s3_gateway).to receive(:read).with("second.attributes").and_return("ATTRIBUTE Foo-Attribute\nATTRIBUTE Bar-Attribute")

      use_case.call
    end

    it "writes the attributes to the output file" do
      expect(s3_gateway).to have_received(:list_object_keys)
      expect(s3_gateway).to have_received(:read).twice

      output_file_content = File.read(output)

      expected_content = <<~ATTRIBUTES
        First-Attribute
        Second-Attribute
        Foo-Attribute
        Bar-Attribute
      ATTRIBUTES

      expect(output_file_content).to eq(expected_content)
    end
  end
end