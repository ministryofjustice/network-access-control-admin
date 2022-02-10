class PoliciesImportsController < ApplicationController
  def new
    @policies_import = UseCases::CSVImport::Policies.new

    authorize! :create, @policies_import
  end

  def create
    filename = params&.dig(:policies, :file)&.original_filename
    contents = params&.dig(:policies, :file)&.read

    csv_import_result = CsvImportResult.create!
  end
end
