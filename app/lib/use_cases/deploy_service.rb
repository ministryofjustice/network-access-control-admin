module UseCases
  class DeployService
    def initialize(ecs_gateway:)
      @ecs_gateway = ecs_gateway
    end

    def call
      ecs_gateway.update_service
    end

    private

    attr_reader :ecs_gateway
  end
end
