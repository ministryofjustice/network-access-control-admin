class MacAuthenticationBypassesImportsController < ApplicationController
  def new
    @mac_authentication_bypasses_import = CSVImport::MacAuthenticationBypasses.new(
      UseCases::AuditMacAuthenticationBypassesImport.new(current_user),
    )

    authorize! :create, @mac_authentication_bypasses_import
  end

  def create
    contents = mac_authentication_bypasses_import_params&.dig(:bypasses)&.read

    @mac_authentication_bypasses_import = CSVImport::MacAuthenticationBypasses.new(
      UseCases::AuditMacAuthenticationBypassesImport.new(current_user),
      contents,
    )

    if @mac_authentication_bypasses_import.save
      publish_authorised_macs
      deploy_service
      redirect_to mac_authentication_bypasses_path, notice: "Successfully imported bypasses"
    else
      render :new
    end
  end

private

  def mac_authentication_bypasses_import_params
    return if params[:csv_import_mac_authentication_bypasses].nil?

    params.require(:csv_import_mac_authentication_bypasses).permit(:bypasses)
  end

  def publish_authorised_macs
    content = UseCases::GenerateAuthorisedMacs.new.call(mac_authentication_bypasses: MacAuthenticationBypass.includes(:responses).all)

    UseCases::PublishToS3.new(
      config_validator: UseCases::ConfigValidator.new(
        config_file_path: RadiusHelper::AUTHORISED_MACS_PATH,
        content: content,
      ),
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
        key: "authorised_macs",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "text/plain",
      ),
    ).call(content)
  end
end
