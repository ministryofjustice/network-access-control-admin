class MacAuthenticationBypassImportJob < ActiveJob::Base
  def perform(contents, csv_import_result, user)
    Audited.audit_class.as_user(user) do
      result = UseCases::CSVImport::MacAuthenticationBypasses.new(contents).call

      if result.fetch(:errors).any?
        csv_import_result.update!(import_errors: result.fetch(:errors).join(","))
      else
        publish_authorised_macs
        deploy_service
      end

      csv_import_result.update!(completed_at: Time.now)
    end
  rescue StandardError => e
    csv_import_result.update!(import_errors: "Error while importing data from CSV: #{e.message}", completed_at: Time.now)

    raise e
  end

private

  def publish_authorised_macs
    content = UseCases::GenerateAuthorisedMacs.new.call(
      mac_authentication_bypasses: MacAuthenticationBypass.includes(:responses).all,
    )

    UseCases::PublishToS3.new(
      config_validator: UseCases::ConfigValidator.new(
        config_file_path: RadiusHelper::AUTHORISED_MACS_PATH,
        content:,
      ),
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
        key: "authorised_macs",
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
