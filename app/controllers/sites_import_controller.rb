class SitesImportController < ApplicationController
  def new
    @sites_with_clients_import = CSVImport::SitesWithClients.new(
      UseCases::CSVImport::ParseSitesWithClients.new(""),
    )

    authorize! :create, @sites_with_clients_import
  end

  def create
    contents = sites_import_params&.dig(:sites_with_clients)&.read

    csv_import_result = CsvImportResult.create!
    SitesWithClientsImportJob.perform_later(contents, csv_import_result)

    @sites_with_clients_import = CSVImport::SitesWithClients.new(
      UseCases::CSVImport::ParseSitesWithClients.new(contents),
    )

    if @sites_with_clients_import.save
      deploy_service
      redirect_to sites_path, notice: "Successfully imported sites with clients"
    else
      render :new
    end
  end

private

  def sites_import_params
    return if params[:csv_import_sites_with_clients].nil?

    params.require(:csv_import_sites_with_clients).permit(:sites_with_clients)
  end
end
