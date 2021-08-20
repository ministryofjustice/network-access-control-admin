class ClientsController < ApplicationController
  before_action :set_site, only: %i[new create edit update destroy]

  SHARED_SECRET_BYTES = 10

  def index; end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params.merge(site_id: @site.id, shared_secret: SecureRandom.hex(SHARED_SECRET_BYTES).upcase, tag: @site.name.parameterize(separator: "_")))

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
    params.require(:client).permit(:ip_range, :tag)
  end

  def publish_authorised_clients
    UseCases::PublishToS3.new(
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
        key: "clients.conf",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "text/plain",
      ),
    ).call(
      UseCases::GenerateAuthorisedClients.new.call(
        clients: Client.all,
      ),
    )
  end
end
