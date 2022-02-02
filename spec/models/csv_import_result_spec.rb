require "rails_helper"

describe CsvImportResult, type: :model do
  subject { build :csv_import_result }

  it "can save errors" do
    errors = %i[
      Duplicate Client
      CSV headers are not valid
    ]

    subject.import_errors = errors
    subject.save

    expect(subject).to be_valid
  end
end
