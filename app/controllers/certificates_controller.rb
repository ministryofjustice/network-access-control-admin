class CertificatesController < ApplicationController
  before_action :set_certificate, only: %i[destroy edit update]
  before_action :set_crumbs, only: %i[index new show destroy]

  def index
    @q = Certificate.ransack(params[:q])
    @certificates = @q.result.page(params.dig(:q, :page))
  end

  def new
    @certificate = Certificate.new
  end

  def create
    @certificate = Certificate.new(certificate_params)
    uploaded_certificate_file = params["certificate"]["certificate"]

    if uploaded_certificate_file.present?
      certificate_metadata = UseCases::ReadCertificateMetadata.new(certificate: uploaded_certificate_file.read).call
      @certificate.expiry_date = certificate_metadata[:expiry_date]
      @certificate.subject = certificate_metadata[:subject]
      @certificate.issuer = certificate_metadata[:issuer]
      @certificate.serial = certificate_metadata[:serial]
      @certificate.extensions = certificate_metadata[:extensions]
      @certificate.filename = server_certificate? ? "server.pem" : uploaded_certificate_file.original_filename
    end

    if @certificate.save
      deploy_service
      redirect_to certificate_path(@certificate), notice: "Successfully uploaded certificate."
      publish_certificate(uploaded_certificate_file, @certificate.filename)
    else
      render :new
    end
  end

  def destroy
    authorize! :destroy, @certificate
    if confirmed?
      if @certificate.destroy
        remove_certificate
        deploy_service
        redirect_to certificates_path, notice: "Successfully deleted certificate. "
      else
        redirect_to certificates_path, error: "Failed to delete the certificate."
      end
    else
      render "certificates/destroy"
    end
  end

  def show
    @certificate = Certificate.find(params.fetch(:id))
  end

private

  def certificate_params
    params.require(:certificate).permit(:name, :description, :category)
  end

  def certificate_id
    params.fetch(:id)
  end

  def server_certificate?
    ActiveModel::Type::Boolean.new.cast(params.dig(:certificate, :server_certificate))
  end

  def set_certificate
    @certificate = Certificate.find(certificate_id)
  end

  def remove_certificate
    UseCases::RemoveFromS3.new(
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("RADIUS_CERTIFICATE_BUCKET_NAME"),
        key: full_object_path(@certificate.filename),
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "text/plain",
      ),
    ).call
  end

  def publish_certificate(certificate_file, filename)
    content = IO.read(certificate_file.to_io)

    UseCases::PublishToS3.new(
      config_validator: UseCases::ConfigValidator.new(
        config_file_path: "/etc/raddb/certs/#{@certificate.filename}",
        content:,
      ),
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("RADIUS_CERTIFICATE_BUCKET_NAME"),
        key: full_object_path(filename),
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "text/plain",
      ),
    ).call(content)
  end

  def full_object_path(filename)
    (@certificate.category == "RADSEC" ? "radsec/" : "") + filename
  end

  def set_crumbs
    @navigation_crumbs << ["Certificates", certificates_path]
  end
end
