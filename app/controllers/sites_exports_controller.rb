class SitesExportsController < ApplicationController
  def new
    sites_with_clients_export = UseCases::CSVExport::SitesWithClients.new

    authorize! :create, sites_with_clients_export
  end

  def create
    sites_with_clients_export = UseCases::CSVExport::SitesWithClients.new.call
    send_data sites_with_clients_export, filename: "sites_with_clients.csv", type: "application/csv"
  end
end
