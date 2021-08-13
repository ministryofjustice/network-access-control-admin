require "rails_helper"

RSpec.describe Site, type: :model do
  subject { build :site }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to have_many(:clients) }
  it { is_expected.to have_and_belong_to_many(:policies) }

  it "only allows to have one fallback policy" do
    subject.policies = [create(:policy, fallback: true), create(:policy, fallback: true)]
    expect(subject).not_to be_valid

    subject.policies = [create(:policy, fallback: true)]
    expect(subject).to be_valid
  end
end
