require "rails_helper"

describe Policy, type: :model do
  subject { build :policy }

  it "has a valid policy" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :description }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to have_many(:rules) }
  it { is_expected.to have_many(:responses) }
  it { is_expected.to have_many(:sites) }
end
