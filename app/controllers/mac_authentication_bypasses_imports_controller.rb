class MacAuthenticationBypassesImportsController < ApplicationController
  def new
    @mac_authentication_bypasses_import = MacAuthenticationBypassesImport.new

    authorize! :create, @mac_authentication_bypasses_import
  end

  def create
    if session[:bypasess_import]
      @mac_authentication_bypasses_import = MacAuthenticationBypassesImport.new(session[:bypasess_import])

      if @mac_authentication_bypasses_import.save
        session.delete(:bypasess_import)

        return redirect_to mac_authentication_bypasses_path, notice: "Successfully imported bypasses"
      end
    else
      contents = mac_authentication_bypasses_import_params[:bypasses].read
      session[:bypasess_import] = contents

      @mac_authentication_bypasses_import = MacAuthenticationBypassesImport.new(contents)
    end

    render :new
  end

private

  def mac_authentication_bypasses_import_params
    params.require(:mac_authentication_bypasses_import).permit(:bypasses)
  end
end
