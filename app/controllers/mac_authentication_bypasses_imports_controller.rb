class MacAuthenticationBypassesImportsController < ApplicationController
  def new
    @mac_authentication_bypasses_import = MacAuthenticationBypassesImport.new

    authorize! :create, @mac_authentication_bypasses_import
  end

  def create
    contents = mac_authentication_bypasses_import_params[:bypasses].read
    @mac_authentication_bypasses_import = MacAuthenticationBypassesImport.new(contents)

    if @mac_authentication_bypasses_import.save
      redirect_to mac_authentication_bypasses_path, notice: "Successfully imported bypasses"
    else
      render :new
    end
  end

private

  def mac_authentication_bypasses_import_params
    params.require(:mac_authentication_bypasses_import).permit(:bypasses)
  end
end
