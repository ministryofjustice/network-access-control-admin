class SitesExportsController < ApplicationController
  before_action :set_sites_crumbs, only: %i[new show]

  def new
    sites_with_clients_export = UseCases::CSVExport::SitesWithClients.new

    authorize! :create, sites_with_clients_export
  end

  def create
    sites_with_clients_export = UseCases::CSVExport::SitesWithClients.new.call
    send_data sites_with_clients_export, filename: "sites_with_clients.csv", type: "application/csv"
  end

private

  def set_sites_crumbs
    @navigation_crumbs << ["Sites", sites_path]
  end
end
