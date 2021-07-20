class CertificatesController < ApplicationController
  before_action :set_certificate, only: %i[destroy edit update]

  def index
    @certificates = Certificate.all
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
      @certificate.filename = uploaded_certificate_file.original_filename
    end

    if @certificate.save
      redirect_to certificate_path(@certificate), notice: "Successfully uploaded certificate."
      publish_certificate(uploaded_certificate_file)
    else
      render :new
    end
  end

  def edit
    authorize! :update, @certificate
  end

  def update
    authorize! :update, @certificate
    @certificate.assign_attributes(certificate_params)

    if @certificate.save
      redirect_to certificate_path(@certificate), notice: "Successfully updated certificate details."
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @certificate
    if confirmed?
      if @certificate.destroy
        redirect_to certificates_path, notice: "Successfully deleted certificate. "

        # TODO: delete certificate from S3
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
    params.require(:certificate).permit(:name, :description)
  end

  def certificate_id
    params.fetch(:id)
  end

  def set_certificate
    @certificate = Certificate.find(certificate_id)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end

  def publish_certificate(certificate_file)
    UseCases::PublishToS3.new(
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("RADIUS_CERTIFICATE_BUCKET_NAME"),
        key: certificate_file.original_filename,
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "text/plain",
      ),
    ).call(
      certificate_file.to_io,
    )
  end
end
