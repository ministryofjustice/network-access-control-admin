require "rails_helper"

# Make sure that https://nvd.nist.gov/vuln/detail/CVE-2015-9284 is mitigated
RSpec.describe "CVE-2015-9284", type: :request do
  describe "GET /auth/:provider" do
    it do
      get "/users/auth/cognito", headers: { "HTTPS" => "on" }
      expect(response).not_to have_http_status(:redirect)
    end
  end

  describe "POST /auth/:provider without CSRF token" do
    before do
      @allow_forgery_protection = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true
    end

    it do
      expect(post("/users/auth/cognito", headers: { "HTTPS" => "on" })).to redirect_to(new_user_session_path)
    end

    after do
      ActionController::Base.allow_forgery_protection = @allow_forgery_protection
    end
  end
end
