describe Gateways::S3 do
  subject(:gateway) do
    described_class.new(bucket: bucket, key: key,
                        aws_config: aws_config, content_type: "application/json")
  end

  let(:bucket) { "StubBucket" }
  let(:key) { "StubKey" }
  let(:data) { { blah: "foobar" }.to_json }
  let(:aws_config) do
    {
      stub_responses: {
        get_object: lambda { |context|
          { body: "some data" } if context.params.fetch(:bucket) == bucket && context.params.fetch(:key) == key
        },
      },
    }
  end

  it "writes the data to the S3 bucket" do
    expect(gateway.write(data: data)).to eq({})
  end

  context "when reading a file from the S3 bucket" do
    it "returns the contents of the file" do
      expect(gateway.read).to eq("some data")
    end
  end
end
