require_relative "../../app/lib/gateways/s3"
require_relative "../../app/lib/use_cases/fetch_radius_attributes"

s3_gateway = Gateways::S3.new(
  bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
  key: nil,
  aws_config: Rails.application.config.s3_aws_config,
  content_type: "text/plain",
)

begin
  attributes = UseCases::FetchRadiusAttributes.new(
    gateway: s3_gateway,
    output: "/usr/share/freeradius/",
  ).call

  Rails.application.config.radius_attributes = attributes
rescue StandardError => e
  pp "Failed to fetch RADIUS dictionaries with error: #{e}"

  raise e
end
