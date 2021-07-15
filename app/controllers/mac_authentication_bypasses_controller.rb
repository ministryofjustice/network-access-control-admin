class MacAuthenticationBypassesController < ApplicationController
  def index
    @mac_authentication_bypasses = MacAuthenticationBypass.all
  end

  def new
    @mac_authentication_bypass = MacAuthenticationBypass.new

    authorize! :create, @mac_authentication_bypass
  end

  def create
    @mac_authentication_bypass = MacAuthenticationBypass.new(mac_authentication_bypass_params)
    authorize! :create, @mac_authentication_bypass

    if @mac_authentication_bypass.save
      redirect_to mac_authentication_bypasses_path, notice: "Successfully created MAC authentication bypass. "
    else
      render :new
    end
  end

  private

  def mac_authentication_bypass_params
    params.require(:mac_authentication_bypass).permit(:address, :name, :description)
  end
end
