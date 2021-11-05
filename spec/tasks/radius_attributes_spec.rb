require "rails_helper"
require "rake"

describe "fetching attributes from radius dictionaries" do
  let(:invoke_rake_task) do
    Rake.application.invoke_task "radius_attributes:fetch"
  end

  let(:s3_gateway) { double(Gateways::S3) }
  let(:fetch_radius_attributes) { double(UseCases::FetchRadiusAttributes) }

  let(:expected_s3_gateway_config) do
    {
      bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
      key: nil,
      aws_config: {},
      content_type: "text/plain",
    }
  end

  before do
    Rake.application.rake_require "tasks/radius_attributes"
  end

  context "when the task is invoked" do
    context "and there is a file in the radius_dictionaries folder" do
      it "does fetch the attributes from the file" do
        expect(Gateways::S3).to receive(:new).with(expected_s3_gateway_config).and_return(s3_gateway)

        expect(UseCases::FetchRadiusAttributes).to receive(:new).with({
          gateway: s3_gateway,
          output: "/usr/share/freeradius/",
        }).and_return(fetch_radius_attributes)

        expect(fetch_radius_attributes).to receive(:call)

        invoke_rake_task
      end
    end
  end
end
