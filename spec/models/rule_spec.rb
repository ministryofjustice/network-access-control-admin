require "rails_helper"

describe Rule, type: :model do
  subject { build :rule }

  it "has a valid rule" do
    expect(subject).to be_valid
  end

  it { is_expected.to belong_to :policy }
  it { is_expected.to belong_to :request_attribute }
  it { is_expected.to validate_presence_of :operator }
  it { is_expected.to validate_presence_of :value }
end
