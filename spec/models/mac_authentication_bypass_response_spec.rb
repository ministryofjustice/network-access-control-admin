require "rails_helper"

describe MacAuthenticationBypassResponse, type: :model do
  subject { build :mac_authentication_bypass_response }

  it "has a valid response" do
    expect(subject).to be_valid
  end

  it { is_expected.to belong_to :mac_authentication_bypass }
  it { is_expected.to validate_presence_of :response_attribute }
  it { is_expected.to validate_presence_of :value }
end