class SitesExportsController < ApplicationController
  def new
    @sites_with_clients_export = UseCases::CSVExport::SitesWithClients.new

    authorize! :create, @sites_with_clients_export
  end

  def create; end
end
