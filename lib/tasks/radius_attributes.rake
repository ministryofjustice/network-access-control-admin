require "./app/lib/gateways/s3"

namespace :radius_attributes do
  desc "Retrieve attributes from RADIUS dictionaries"
  task :fetch do
    s3_gateway = Gateways::S3.new(
      bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
      key: "radius_dictionaries/dummy.dum",
      aws_config: {},
      content_type: "text/plain",
    )

    s3_gateway.read
  end
end
