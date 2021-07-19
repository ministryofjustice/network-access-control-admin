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
    end

    if @certificate.save
      redirect_to certificate_path(@certificate), notice: "Successfully uploaded certificate."
      publish_certificate
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

  def publish_certificate; end
end
