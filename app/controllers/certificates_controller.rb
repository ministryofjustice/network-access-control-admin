class CertificatesController < ApplicationController
  def index; end

  def new
    @certificate = Certificate.new
  end

  def create
    uploaded_certificate = params["certificate"]["certificate"]

    # Write data into temp file
    File.open(Rails.root.join("public", "uploads", uploaded_certificate.original_filename), "wb") do |file|
      file.write(uploaded_certificate.read)
    end

    # Read file data
    certificate = File.open(Rails.root.join("public", "uploads", uploaded_certificate.original_filename)).read

    # TODO: Create a use-case to read expiry_date and metadata from file
    # and merge with the :name and :description params, something like:
    expiry_date = UseCases::ReadCertificateMetadata.new(certificate: certificate).call

    @certificate = Certificate.new(certificate_params.merge(expiry_date: expiry_date))

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
