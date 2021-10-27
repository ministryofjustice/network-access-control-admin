module DeploymentFeatureHelpers
  def expect_service_deployment
    deploy_service = instance_double(UseCases::DeployService)
    ecs_gateway = double(Gateways::Ecs)
    allow(deploy_service).to receive(:call)

    expected_ecs_gateway_config = {
      cluster_name: ENV.fetch("RADIUS_CLUSTER_NAME"),
      service_name: ENV.fetch("RADIUS_SERVICE_NAME"),
      aws_config: Rails.application.config.ecs_aws_config,
    }

    expected_ecs_gateway_config_internal = {
      cluster_name: ENV.fetch("RADIUS_CLUSTER_NAME"),
      service_name: ENV.fetch("RADIUS_INTERNAL_SERVICE_NAME"),
      aws_config: Rails.application.config.ecs_aws_config,
    }

    expect(Gateways::Ecs).to receive(:new).with(expected_ecs_gateway_config).and_return(ecs_gateway)
    expect(UseCases::DeployService).to receive(:new).with(ecs_gateway: ecs_gateway).and_return(deploy_service)

    expect(Gateways::Ecs).to receive(:new).with(expected_ecs_gateway_config_internal).and_return(ecs_gateway)
    expect(UseCases::DeployService).to receive(:new).with(ecs_gateway: ecs_gateway).and_return(deploy_service)
  end
end
