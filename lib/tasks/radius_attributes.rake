require "./app/lib/gateways/s3"
require "./app/lib/use_cases/fetch_radius_attributes"

namespace :radius_attributes do
  desc "Retrieve attributes from RADIUS dictionaries"
  task :fetch do
    s3_gateway = Gateways::S3.new(
      bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
      key: nil,
      aws_config: {},
      content_type: "text/plain",
    )

    begin
      pp "Fetching Radius attibutes"

      UseCases::FetchRadiusAttributes.new(
        gateway: s3_gateway,
        output: "app/helpers/radius_dictionary_attributes.txt",
      ).call
    rescue StandardError => e
      pp "Failed to fetch attributes with error: #{e}"
      raise e
    end
  end
end
