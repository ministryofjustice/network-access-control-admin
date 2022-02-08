class MacAuthenticationBypassesImportsController < ApplicationController
  before_action :set_bypasses_crumbs, only: %i[new show]
  before_action :set_bypasses_imports_crumbs, only: %i[show]

  def new
    @mac_authentication_bypasses_import = UseCases::CSVImport::MacAuthenticationBypasses.new

    authorize! :create, @mac_authentication_bypasses_import
  end

  def create
    filename = mac_authentication_bypasses_import_params.fetch(:file).original_filename
    contents = mac_authentication_bypasses_import_params.fetch(:file).read

    csv_import_result = CsvImportResult.create!
    MacAuthenticationBypassImportJob.perform_later({ contents:, filename: }, csv_import_result, current_user)

    redirect_to mac_authentication_bypasses_import_path(csv_import_result), notice: "Importing MAC addresses"
  end

  def show
    @csv_import_result = CsvImportResult.find(params.fetch(:id))
  end

private

  def set_bypasses_crumbs
    @navigation_crumbs << ["MAC Authentication Bypasses", mac_authentication_bypasses_path]
  end

  def set_bypasses_imports_crumbs
    @navigation_crumbs << ["MAC Authentication Bypasses Imports", new_mac_authentication_bypasses_import_path]
  end

  def mac_authentication_bypasses_import_params
    params.require(:bypasses).permit(:file)
  end
end
