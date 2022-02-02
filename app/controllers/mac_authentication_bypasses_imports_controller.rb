class MacAuthenticationBypassesImportsController < ApplicationController
  before_action :set_crumbs, only: %i[new show]

  def new
    @mac_authentication_bypasses_import = UseCases::CSVImport::MacAuthenticationBypasses.new

    authorize! :create, @mac_authentication_bypasses_import
  end

  def create
    contents = mac_authentication_bypasses_import_params.fetch(:file).read

    csv_import_result = CsvImportResult.create!
    MacAuthenticationBypassImportJob.perform_later(contents, csv_import_result)

    redirect_to mac_authentication_bypasses_import_path(csv_import_result), notice: "Importing MAC addresses"
  end

  def show
    @csv_import_result = CsvImportResult.find(params.fetch(:id))
  end

private

  def set_crumbs
    @navigation_crumbs << ["MAC Authentication Bypasses", mac_authentication_bypasses_path]
  end

  def mac_authentication_bypasses_import_params
    params.require(:bypasses).permit(:file)
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
