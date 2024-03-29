class ClientsController < ApplicationController
  before_action :set_site, only: %i[new create edit update destroy]
  before_action :set_crumbs, only: %i[new edit destroy]

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params.merge(site_id: @site.id))

    if @client.save
      publish_authorised_clients
      deploy_service
      redirect_to site_path(@site), notice: "Successfully created client."
    else
      render :new
    end
  end

  def edit
    @client = Client.find(params.fetch(:id))
    authorize! :update, @client
  end

  def update
    @client = Client.find(params.fetch(:id))
    authorize! :update, @client

    @client.assign_attributes(client_params)

    if @client.save
      publish_authorised_clients
      deploy_service
      redirect_to site_path(@site), notice: "Successfully updated client. "
    else
      render :edit
    end
  end

  def destroy
    @client = Client.find(params.fetch(:id))

    authorize! :destroy, @client
    if confirmed?
      if @client.destroy
        publish_authorised_clients
        deploy_service
        redirect_to site_path(@site), notice: "Successfully deleted client. "
      else
        redirect_to site_path(@site), error: "Failed to delete the client. "
      end
    else
      render "clients/destroy"
    end
  end

private

  def site_id
    params.fetch(:site_id)
  end

  def set_site
    @site = Site.find(site_id)
  end

  def client_params
    params.require(:client).permit(:ip_range, :radsec, :shared_secret)
  end

  def set_crumbs
    @navigation_crumbs << ["Sites", sites_path]
  end
end
