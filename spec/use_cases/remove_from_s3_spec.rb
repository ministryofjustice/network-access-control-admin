require "rails_helper"

describe UseCases::RemoveFromS3 do
  subject(:use_case) do
    described_class.new(
      destination_gateway: s3_gateway,
    )
  end

  let(:s3_gateway) { instance_spy(Gateways::S3) }

  before do
    use_case.call
  end

  it "removes the file from S3" do
    expect(s3_gateway).to have_received(:remove)
  end
end
