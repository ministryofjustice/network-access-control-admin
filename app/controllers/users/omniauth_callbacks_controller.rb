class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :developer if Rails.env.development?

  def cognito
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect @user
  end

  def developer
    @user = User.from_developer_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect @user
  end

  def failure
    redirect_to root_path
  end
end
