require "rails_helper"

describe Certificate, type: :model do
  subject { build :certificate }

  it "has a valid certificate" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :description }
  it { is_expected.to validate_presence_of :expiry_date }
  it { is_expected.to validate_presence_of :properties }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end
