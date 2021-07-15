class MacAuthenticationBypassesController < ApplicationController
  def index
    @mac_authentication_bypasses = MacAuthenticationBypass.all
  end
end
