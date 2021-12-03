class UseCases::PublishToS3
  def initialize(destination_gateway:, config_validator:)
    @destination_gateway = destination_gateway
    @config_validator = config_validator
  end

  def call(config)
    validate_config!
    destination_gateway.write(data: config)
  end

private

  def validate_config!
    config_validator.call
  end

  attr_reader :destination_gateway, :config_validator
end
