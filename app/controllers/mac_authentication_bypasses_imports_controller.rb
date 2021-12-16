class MacAuthenticationBypassesImportsController < ApplicationController
  def new
    @mac_authentication_bypasses_import = MacAuthenticationBypassesImport.new
    authorize! :create, @mac_authentication_bypasses_import
  end

  def create
    redirect_to mac_authentication_bypasses_path, notice: "Successfully imported bypasses"
  end
end
