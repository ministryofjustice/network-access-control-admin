require "rails_helper"

describe UseCases::FetchRadiusAttributes do
  subject(:use_case) do
    described_class.new(
      gateway: s3_gateway,
      output: output,
    )
  end

  let(:s3_gateway) { instance_spy(Gateways::S3) }
  let(:output) { "spec/use_cases/attributes.json" }
  let(:content) { File.read("spec/use_cases/attributes.vendor") }

  before do
    allow(s3_gateway).to receive(:read).and_return(content)

    use_case.call
  end

  it "writes the attributes to the output file" do
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
