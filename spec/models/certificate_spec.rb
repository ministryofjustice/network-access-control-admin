require "rails_helper"

describe Certificate, type: :model do
  subject { build :certificate }

  it "has a valid certificate" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :description }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_uniqueness_of(:filename).case_insensitive }


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
