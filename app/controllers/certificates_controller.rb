class CertificatesController < ApplicationController
  def index
  end

  def new
    @certificate = Certificate.new
  end

  def create
    # TODO Create a use-case to read expiry_date and metadata from file
    # and merge with the :name and :description params, something like: 
    # certificate_metadata = UseCases::ReadCertificate(file).execute
    @certificate = Certificate.new(certificate_params)

    if @certificate.save
      redirect_to certificate_path(@certificate), notice: "Successfully uploaded certificate."
    else
      render :new
    end
  end

private

  def certificate_params
    params.require(:certificate).permit(:name, :description)
  end
end
