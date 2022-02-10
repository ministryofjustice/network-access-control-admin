class PoliciesImportsController < ApplicationController
  def new
    @policies_import = UseCases::CSVImport::Policies.new

    authorize! :create, @policies_import
  end
end
