require "rails_helper"

describe PolicyResponse, type: :model do
  subject { build :policy_response }

  it "has a valid response" do
    expect(subject).to be_valid
  end

  it { is_expected.to belong_to :policy }
  it { is_expected.to validate_presence_of :response_attribute }
  it { is_expected.to validate_presence_of :value }
end
