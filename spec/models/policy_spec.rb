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
  it { is_expected.to have_many(:site_policy) }
  it { is_expected.to have_many(:sites) }

  it "persist and updates the site count" do
    policy = create(:policy)
    site = create(:site)
    expect(policy.site_count).to eq(0)

    policy.sites << site
    expect(policy.site_count).to eq(1)

    policy.assign_attributes(sites: [])
    policy.save

    expect(policy.site_count).to eq(0)
    expect(policy.default_accept?).to eq(true)
    expect(policy.default_reject?).to eq(false)
    expect(policy.action).to eq("accept")
  end

  it "updates an accept policy to a default reject policy" do
    policy = create(:policy)
    policy.responses << create(:response, response_attribute: "Post-Auth-Type", value: "Reject")

    expect(policy.default_accept?).to eq(false)
    expect(policy.default_reject?).to eq(true)
    expect(policy.action).to eq("reject")
  end
end
