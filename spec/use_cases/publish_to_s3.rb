require "rails_helper"

describe UseCases::PublishToS3 do
  subject(:use_case) do
    described_class.new(
      destination_gateway: s3_gateway
    )
  end

  let(:s3_gateway) { instance_spy(Gateways::S3) }
  let(:config) { "any file contents" }

  before do
    use_case.call(config)
  end

  it "publishes the file with contents" do
    expect(s3_gateway).to have_received(:write)
      .with(data: config)
  end
end
