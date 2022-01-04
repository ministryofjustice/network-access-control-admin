require "rails_helper"

describe UseCases::ValidateRadiusAttributes do
  subject(:use_case) do
    described_class.new(records: records, errors: errors)
  end

  let(:errors) do
    CSVImport::MacAuthenticationBypasses.new.errors
  end

  let(:invalid_response) do
    build(:mab_response, response_attribute: "3Com-Connect_Id", value: "Invalid")
  end

  let(:records) do
    [
      build(:mac_authentication_bypass, responses: [invalid_response]),
    ]
  end

  it "adds an error" do
    use_case.call

    expect(errors.full_messages).to include "Error on row 2: Unknown or invalid value \"Invalid\" for attribute 3Com-Connect_Id"
  end
end
