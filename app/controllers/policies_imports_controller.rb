class PoliciesImportsController < ApplicationController
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
end
