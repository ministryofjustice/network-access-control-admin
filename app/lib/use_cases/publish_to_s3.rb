class UseCases::PublishToS3
  def initialize(destination_gateway:)
    @destination_gateway = destination_gateway
  end

  def call(config)
    destination_gateway.write(data: config)
  end

  private

  attr_reader :destination_gateway
end
