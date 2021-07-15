require "rails_helper"

describe MacAuthenticationBypass, type: :model do
  subject { build :mac_authentication_bypass }

  it "has a valid bypass" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :address }
  it { is_expected.to validate_uniqueness_of(:address).case_insensitive }
end
