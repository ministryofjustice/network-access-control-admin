class UseCases::RemoveFromS3
  def initialize(destination_gateway:)
    @destination_gateway = destination_gateway
  end

  def call
    destination_gateway.remove
  end

private

  attr_reader :destination_gateway
end
