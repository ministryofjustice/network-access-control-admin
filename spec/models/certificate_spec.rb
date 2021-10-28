require "rails_helper"

describe Certificate, type: :model do
  subject { build :certificate }

  it "has a valid certificate" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :description }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  describe "validate uniquness of filename" do
    it "rejects duplicate filenames of the same category" do
      create(:certificate, filename: "server.pem", category: "EAP")
      expect { create(:certificate, filename: "server.pem", category: "EAP") }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "allows duplicate filenames of the different categories" do
      create(:certificate, filename: "server.pem", category: "RADSEC")
      expect { create(:certificate, filename: "server.pem", category: "EAP") }.not_to raise_error
    end
  end

  describe "validate the certificate is in pem format" do
    it "rejects file extension of cer" do
      params = { name: "Wrong certificate extension", description: "CER format", filename: "wrong_extension.cer", category: "EAP" }
      expect { create(:certificate, params) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  it "raises an error when fields from certificate file are missing" do
    missing_field = [{ expiry_date: Date.today }, { subject: "may not exist" }].sample
    params = { name: "My new certificate", description: "bar" }.merge(missing_field)
    invalid_cerificate = Certificate.new(params)

    expect(invalid_cerificate).to_not be_valid
    expect(invalid_cerificate.errors.full_messages).to include("Certificate is missing or invalid")
  end

  it "validates the category of certificate" do
    expect(build(:certificate, category: "foobar")).to be_invalid
    expect(build(:certificate, category: "EAP")).to be_valid
    expect(build(:certificate, category: "RADSEC")).to be_valid
  end
end
