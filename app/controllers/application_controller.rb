class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  after_action :set_expect_ct_header

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

private

  def set_expect_ct_header
    response.headers["Expect-CT"] = "max-age=86400, enforce"
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  CONFIG_UPDATE_DELAY_NOTICE = " This could take up to 10 minutes to apply.".freeze
end
