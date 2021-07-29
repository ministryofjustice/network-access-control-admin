class ClientsController < ApplicationController
  before_action :set_site, only: %i[new create edit update]

  def index; end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params.merge(site_id: @site.id))

    if @client.save
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
      redirect_to site_path(@site), notice: "Successfully updated client. "
    else
      render :edit
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
    params.require(:client).permit(:ip_range, :tag, :shared_secret)
  end
end
