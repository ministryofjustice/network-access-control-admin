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
        bucket:,
        key:,
        content_type:,
      )

      {}
    end

    def read(file = key, target = nil)
      client.get_object({ bucket:, key: file }, target:)
    end

    def remove
      client.delete_object(bucket:, key:).to_h
    end

    def list_object_keys(prefix, max_keys = 1000)
      client.list_objects_v2(bucket:, max_keys:, prefix:)
    end

  private

    attr_reader :bucket, :key, :client, :content_type
  end
end
