module Gateways
  class S3
    def initialize(bucket:, key:, aws_config:, content_type:)
      @bucket = bucket
      @key = key
      @client = Aws::S3::Client.new(aws_config)
      @content_type = content_type
    end

    def write(data:)
      client.put_object(
        body: data,
        bucket: bucket,
        key: key,
        content_type: content_type
      )

      {}
    end

    def read
      client.get_object(bucket: bucket, key: key).body.read
    end

    private

    attr_reader :bucket, :key, :client, :content_type
  end
end
