class SitesWithClientsImportJob < ActiveJob::Base
  def perform(contents, csv_import_result)
    result = UseCases::CSVImport::SitesWithClients.new(contents).save

    if result.fetch(:errors).any?
      csv_import_result.update!(import_errors: result.fetch(:errors).join(","))
    else
      publish_authorised_clients
      deploy_service
    end

    csv_import_result.update!(completed_at: Time.now)
  end

private

  def publish_authorised_clients
    content = UseCases::GenerateAuthorisedClients.new.call(
      clients: Client.where.not(shared_secret: "radsec").includes(:site),
      radsec_clients: Client.where(shared_secret: "radsec").includes(:site),
    )

    UseCases::PublishToS3.new(
      config_validator: UseCases::ConfigValidator.new(
        config_file_path: RadiusHelper::AUTHORISED_CLIENTS_PATH,
        content: content,
      ),
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
        key: "clients.conf",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "text/plain",
      ),
    ).call(content)
  end

  def deploy_service
    UseCases::DeployService.new(
      ecs_gateway: Gateways::Ecs.new(
        cluster_name: ENV.fetch("RADIUS_CLUSTER_NAME"),
        service_name: ENV.fetch("RADIUS_SERVICE_NAME"),
        aws_config: Rails.application.config.ecs_aws_config,
      ),
    ).call

    UseCases::DeployService.new(
      ecs_gateway: Gateways::Ecs.new(
        cluster_name: ENV.fetch("RADIUS_CLUSTER_NAME"),
        service_name: ENV.fetch("RADIUS_INTERNAL_SERVICE_NAME"),
        aws_config: Rails.application.config.ecs_aws_config,
      ),
    ).call
  end
end