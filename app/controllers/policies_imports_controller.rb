class PoliciesImportsController < ApplicationController
  before_action :set_policies_crumbs, only: %i[new show]
  before_action :set_policies_imports_crumbs, only: %i[show]

  def new
    @policies_import = UseCases::CSVImport::Policies.new

    authorize! :create, @policies_import
  end

  def create
    filename = params&.dig(:policies, :file)&.original_filename
    contents = params&.dig(:policies, :file)&.read

    csv_import_result = CsvImportResult.create!
    PolicyImportJob.perform_later({ contents:, filename: }, csv_import_result, current_user)

    redirect_to policies_import_path(csv_import_result), notice: "Importing policies"
  end

  def show
    @csv_import_result = CsvImportResult.find(params.fetch(:id))
  end

private

  def set_policies_crumbs
    @navigation_crumbs << ["Policies", policies_path]
  end

  def set_policies_imports_crumbs
    @navigation_crumbs << ["Policies Imports", new_policies_import_path]
  end
end
