class CertificatesController < ApplicationController
  def index; end

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
    else
      render :new
    end
  end

  def show
    @certificate = Certificate.find(params.fetch(:id))
  end

private

  def certificate_params
    params.require(:certificate).permit(:name, :description)
  end
end
