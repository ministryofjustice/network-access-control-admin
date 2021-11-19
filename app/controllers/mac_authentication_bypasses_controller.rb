class MacAuthenticationBypassesController < ApplicationController
  before_action :set_mac_authentication_bypass, only: %i[destroy edit update show]
  before_action :set_crumbs, only: %i[index new show edit destroy]

  def index
    @mac_authentication_bypasses = if params[:search]
                                     @search = params[:search]
                                     MacAuthenticationBypass.where(
                                       MacAuthenticationBypass.arel_table[:address].matches("%#{@search}%"),
                                     ).or(
                                       MacAuthenticationBypass.where(
                                         MacAuthenticationBypass.arel_table[:name].matches("%#{@search}%"),
                                       ).or(
                                         MacAuthenticationBypass.where(
                                           MacAuthenticationBypass.arel_table[:description].matches("%#{@search}%"),
                                         ),
                                       ),
                                     ).page(params[:page])
                                   else
                                     MacAuthenticationBypass.page params[:page]
                                   end
  end

  def new
    @mac_authentication_bypass = MacAuthenticationBypass.new

    authorize! :create, @mac_authentication_bypass
  end

  def create
    @mac_authentication_bypass = MacAuthenticationBypass.new(mac_authentication_bypass_params)
    authorize! :create, @mac_authentication_bypass

    if @mac_authentication_bypass.save
      publish_authorised_macs
      deploy_service
      redirect_to mac_authentication_bypass_path(@mac_authentication_bypass), notice: "Successfully created MAC authentication bypass. "
    else
      render :new
    end
  end

  def destroy
    authorize! :destroy, @mac_authentication_bypass
    if confirmed?
      if @mac_authentication_bypass.destroy
        publish_authorised_macs
        deploy_service
        redirect_to mac_authentication_bypasses_path, notice: "Successfully deleted MAC authentication bypass. "
      else
        redirect_to mac_authentication_bypasses_path, error: "Failed to delete the MAC authentication bypass"
      end
    else
      render "mac_authentication_bypasses/destroy"
    end
  end

  def edit
    authorize! :update, @mac_authentication_bypass
  end

  def update
    authorize! :update, @mac_authentication_bypass
    @mac_authentication_bypass.assign_attributes(mac_authentication_bypass_params)

    if @mac_authentication_bypass.save
      publish_authorised_macs
      deploy_service
      redirect_to mac_authentication_bypass_path(@mac_authentication_bypass), notice: "Successfully updated MAC authentication bypass. "
    else
      render :edit
    end
  end

  def show; end

private

  def mac_authentication_bypass_params
    params.require(:mac_authentication_bypass).permit(:address, :name, :description)
  end

  def mac_authentication_bypass_id
    params.fetch(:id)
  end

  def set_mac_authentication_bypass
    @mac_authentication_bypass = MacAuthenticationBypass.find(mac_authentication_bypass_id)
  end

  def publish_authorised_macs
    UseCases::PublishToS3.new(
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
        key: "authorised_macs",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "text/plain",
      ),
    ).call(
      UseCases::GenerateAuthorisedMacs.new.call(
        mac_authentication_bypasses: MacAuthenticationBypass.all,
      ),
    )
  end

  def set_crumbs
    @navigation_crumbs << ["MAC Authentication Bypasses", mac_authentication_bypasses_path]
  end
end
