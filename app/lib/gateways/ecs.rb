require "aws-sdk-ecs"

module Gateways
  class Ecs
    def initialize(cluster_name:, service_name:, aws_config:)
      @client = Aws::ECS::Client.new(aws_config)
      @cluster_name = cluster_name
      @service_name = service_name
    end

    def update_service
      client.update_service(
        cluster: cluster_name,
        service: service_name,
        force_new_deployment: true,
      )

      {}
    end

  private

    attr_reader :client, :cluster_name, :service_name
  end
end
