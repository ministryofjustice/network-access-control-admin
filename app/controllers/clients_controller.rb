class ClientsController < ApplicationController
  before_action :set_site, only: %i[new create edit update destroy]
  before_action :set_crumbs, only: %i[new edit destroy]

  SHARED_SECRET_BYTES = 10
  RADSEC_SHARED_SECRET = "radsec".freeze

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params.merge(site_id: @site.id, shared_secret: shared_secret))

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

  def radsec?
    radsec = params.require(:client).fetch(:radsec)
    ActiveRecord::Type::Boolean.new.cast(radsec)
  end

  def publish_authorised_clients
    content = UseCases::GenerateAuthorisedClients.new.call(
      clients: Client.where.not(shared_secret: "radsec").includes(:site),
      radsec_clients: Client.where(shared_secret: "radsec").includes(:site),
    )

    UseCases::PublishToS3.new(
      config_validator: UseCases::ConfigValidator.new(
        config_file_path: RadiusHelper::AUTHORISED_CLIENTS_PATH,
        content: content,
      ),
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
        key: "clients.conf",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "text/plain",
      ),
    ).call(content)
  end

  def set_crumbs
    @navigation_crumbs << ["Sites", sites_path]
  end

  def shared_secret
    radsec? ? RADSEC_SHARED_SECRET : SecureRandom.hex(SHARED_SECRET_BYTES).upcase
  end
end
