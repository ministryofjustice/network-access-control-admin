class PolicyImportJob < ActiveJob::Base
  def perform(contents, csv_import_result, user)
    Audited.audit_class.as_user(user) do
      result = UseCases::CSVImport::Policies.new(contents).call

      if result.fetch(:errors).any?
        csv_import_result.update!(import_errors: result.fetch(:errors).join(","))
      end

      csv_import_result.update!(completed_at: Time.now)
    rescue StandardError => e
      csv_import_result.update!(import_errors: "Error while importing data from CSV: #{e.message}", completed_at: Time.now)

      raise e
    end
  end
end
