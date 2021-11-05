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
        content_type: content_type,
      )

      {}
    end

    def read(file = key)
      client.get_object(bucket: bucket, key: file).body.read
    end

    def remove
      client.delete_object(bucket: bucket, key: key).to_h
    end

    def list_object_keys(prefix, max_keys = 1000)
      client.list_objects_v2(bucket: bucket, max_keys: max_keys, prefix: prefix)
    end

    def get_object(key, file)
      client.get_object({ bucket: bucket, key: key }, target: file)
    end

  private

    attr_reader :bucket, :key, :client, :content_type
  end
end
