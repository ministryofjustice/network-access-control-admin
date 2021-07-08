require "rails_helper"

describe RequestAttribute, type: :model do
  subject { build :request_attribute }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :key }
end
