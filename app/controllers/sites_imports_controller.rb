class SitesImportsController < ApplicationController
  before_action :set_sites_crumbs, only: %i[new show]
  before_action :set_sites_imports_crumbs, only: %i[show]

  def new
    @sites_with_clients_import = UseCases::CSVImport::SitesWithClients.new

    authorize! :create, @sites_with_clients_import
  end

  def create
    contents = params&.dig(:sites_with_clients, :file)&.read

    csv_import_result = CsvImportResult.create!
    SitesWithClientsImportJob.perform_later(contents, csv_import_result, current_user)

    redirect_to sites_import_path(csv_import_result), notice: "Importing sites with clients"
  end

  def show
    @csv_import_result = CsvImportResult.find(params.fetch(:id))
  end

private

  def set_sites_crumbs
    @navigation_crumbs << ["Sites", sites_path]
  end

  def set_sites_imports_crumbs
    @navigation_crumbs << ["Sites with Clients Imports", new_sites_import_path]
  end
end
