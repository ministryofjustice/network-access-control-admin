class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :set_default_breadcrumbs, :set_radius_attributes
  after_action :set_expect_ct_header

  helper_method :certificate_expiry_check

  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_to new_user_session_path
  end

  def new_session_path(_scope)
    new_user_session_path
  end

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html", status: :not_found }
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to main_app.root_path, notice: exception.message }
    end
  end

  def error
    if user_signed_in?
      respond_to do |format|
        format.html { render file: "#{Rails.root}/public/404.html", status: :not_found }
      end
    else
      redirect_to new_user_session_path
    end
  end

protected

  def publish_authorised_clients
    content = UseCases::GenerateAuthorisedClients.new.call(
      clients: Client.where.not(shared_secret: "radsec").includes(:site),
      radsec_clients: Client.where(shared_secret: "radsec").includes(:site),
    )

    UseCases::PublishToS3.new(
      config_validator: UseCases::ConfigValidator.new(
        config_file_path: RadiusHelper::AUTHORISED_CLIENTS_PATH,
        content:,
      ),
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
        key: "clients.conf",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "text/plain",
      ),
    ).call(content)
  end

  def deploy_service
    UseCases::DeployService.new(
      ecs_gateway: Gateways::Ecs.new(
        cluster_name: ENV.fetch("RADIUS_CLUSTER_NAME"),
        service_name: ENV.fetch("RADIUS_SERVICE_NAME"),
        aws_config: Rails.application.config.ecs_aws_config,
      ),
    ).call

    UseCases::DeployService.new(
      ecs_gateway: Gateways::Ecs.new(
        cluster_name: ENV.fetch("RADIUS_CLUSTER_NAME"),
        service_name: ENV.fetch("RADIUS_INTERNAL_SERVICE_NAME"),
        aws_config: Rails.application.config.ecs_aws_config,
      ),
    ).call
  end

private

  def set_expect_ct_header
    response.headers["Expect-CT"] = "max-age=86400, enforce"
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def confirmed?
    params.fetch(:confirm, false)
  end

  def set_default_breadcrumbs
    @navigation_crumbs = [["Home", root_path]]
  end

  def set_radius_attributes
    @radius_attributes = Rails.application.config.radius_attributes
  end

  def certificate_expiry_check
    Certificate.where('expiry_date >= ? AND expiry_date <= ?', Date.today, 30.months.from_now.to_date).exists?
  end

  CONFIG_UPDATE_DELAY_NOTICE = " This could take up to 10 minutes to apply.".freeze
end
