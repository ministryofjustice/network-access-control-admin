class MacAuthenticationBypassesImportsController < ApplicationController
  def new
    @mac_authentication_bypasses_import = MacAuthenticationBypassesImport.new
    authorize! :create, @mac_authentication_bypasses_import
  end

  def create
    contents = params["mac_authentication_bypasses_import"]["bypasses"].read
    @mac_authentication_bypasses_import = MacAuthenticationBypassesImport.new(contents)

    if params[:confirmed].present?
      if @mac_authentication_bypasses_import.save
        redirect_to mac_authentication_bypasses_path, notice: "Successfully imported bypasses"
      end
    else
      render :confirm
    end
  end

private

  def mac_authentication_bypasses_imports_params
    params.require(:mac_authentication_bypasses_imports).permit(:bypasses)
  end
end
