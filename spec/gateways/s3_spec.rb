require "rails_helper"

describe Gateways::S3 do
  subject(:gateway) do
    described_class.new(bucket: bucket, key: key,
                        aws_config: aws_config, content_type: "application/json")
  end

  let(:bucket) { "StubBucket" }
  let(:key) { "StubKey" }
  let(:prefix) { "StubPrefix" }
  let(:data) { { blah: "foobar" }.to_json }
  let(:aws_config) do
    {
      stub_responses: {
        get_object: lambda { |context|
          { body: "some data" } if context.params.fetch(:bucket) == bucket && context.params.fetch(:key) == key
        },
        list_objects_v2: lambda { |context|
          ["dictionary.one", "dictionary.two"] if context.params.fetch(:prefix) == prefix
        }
      },
    }
  end

  it "writes the data to the S3 bucket" do
    expect(gateway.write(data: data)).to eq({})
  end

  it "removes the file from the S3 bucket" do
    expect(gateway.remove).to eq(
      {
        delete_marker: false,
        request_charged: "RequestCharged",
        version_id: "ObjectVersionId",
      },
    )
  end

  context "when reading a file from the S3 bucket" do
    it "returns the contents of the file" do
      expect(gateway.read).to eq("some data")
    end

    it "does read a given file" do
      expect(gateway.read(key)).to eq("some data")
    end
  end

  context "when reading multiples files from the S3 bucket" do
    it "returns a list of file names" do
      list_objects = gateway.list_object_keys(prefix)

      expect(list_objects).to eq(["dictionary.one", "dictionary.two"])
    end
  end
end
