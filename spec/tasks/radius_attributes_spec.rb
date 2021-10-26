require "rails_helper"
require "rake"

describe "fetching attributes from radius dictionaries" do
  let(:invoke_rake_task) do
    Rake.application.invoke_task "radius_attributes:fetch"
  end
  let(:s3_gateway) { double(Gateways::S3) }
  let(:expected_s3_gateway_config) do
    {
      bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
      key: "radius_dictionaries/dummy.dum",
      aws_config: {},
      content_type: "text/plain",
    }
  end

  before do
    Rake.application.rake_require "tasks/radius_attributes"
    allow(s3_gateway).to receive(:read)
  end

  context "when the task is invoked" do
    context "and there is a file in the radius_dictionaries folder" do
      it "does fetch the attributes from the file" do
        expect(Gateways::S3).to receive(:new).with(expected_s3_gateway_config).and_return(s3_gateway)

        invoke_rake_task
      end
    end
  end
end
