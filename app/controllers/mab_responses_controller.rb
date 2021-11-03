class MabResponsesController < ApplicationController
  before_action :set_mac_authentication_bypass, only: %i[new create destroy edit update]
  before_action :set_crumbs, only: %i[new edit destroy]

  def new
    @response = MabResponse.new
  end

  def create
    @response = MabResponse.new(response_params.merge(mac_authentication_bypass_id: @mac_authentication_bypass.id))
    authorize! :create, @response

    if @response.save
      publish_authorised_macs
      deploy_service

      redirect_to mac_authentication_bypass_path(@mac_authentication_bypass), notice: "Successfully created response."
    else
      render :new
    end
  end

  def destroy
    @response = MabResponse.find(params.fetch(:id))

    authorize! :destroy, @response
    if confirmed?
      if @response.destroy
        publish_authorised_macs
        deploy_service

        redirect_to mac_authentication_bypass_path(@mac_authentication_bypass), notice: "Successfully deleted response. "
      else
        redirect_to mac_authentication_bypass_path(@mac_authentication_bypass), error: "Failed to delete the response. "
      end
    else
      render "mab_responses/destroy"
    end
  end

  def edit
    @response = MabResponse.find(params.fetch(:id))
    authorize! :update, @response
  end

  def update
    @response = MabResponse.find(params.fetch(:id))
    authorize! :update, @response

    @response.assign_attributes(response_params)

    if @response.save
      publish_authorised_macs
      deploy_service

      redirect_to mac_authentication_bypass_path(@mac_authentication_bypass), notice: "Successfully updated response. "
    else
      render :edit
    end
  end

private

  def mac_authentication_bypass_id
    params.fetch(:mac_authentication_bypass_id)
  end

  def response_params
    response_parameters = params.require(:mab_response).permit(:response_attribute, :value)

    if params[:mab_response][:'response-attribute'] == "custom"
      response_parameters[:response_attribute] = params[:mab_response][:custom_response_attribute]
    end

    response_parameters
  end

  def set_mac_authentication_bypass
    @mac_authentication_bypass = MacAuthenticationBypass.find(mac_authentication_bypass_id)
  end

  def set_crumbs
    @navigation_crumbs << ["MAC Authentication Bypasses", mac_authentication_bypasses_path]
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
end
