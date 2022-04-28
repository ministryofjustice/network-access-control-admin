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
    expect(policy.default_type).to eq("accept")
  end

  it "persist a new reject policy" do
    policy = create(:policy, default_accept: false)

    expect(policy.default_accept?).to eq(false)
    expect(policy.default_reject?).to eq(true)
    expect(policy.default_type).to eq("reject")
    expect(policy.responses.count).to eq(1)
    expect(policy.responses.first.response_attribute).to eq("Post-Auth-Type")
    expect(policy.responses.first.value).to eq("Reject")
  end
<<<<<<< HEAD

  it "updates a accept policy to an reject policy"
  

  it "updates a reject policy to an accept policy" do
    policy = create(:policy, default_accept: false)
    expect(policy.responses.first.response_attribute).to eq("Post-Auth-Type")
    expect(policy.responses.first.value).to eq("Reject")
    policy.default_accept = true
    policy.save!

    expect(policy.default_accept?).to eq(true)
    expect(policy.responses.count).to eq(0)
  end


  it "persists an existing reject policy"

  it "persists an existing policy containing Post-Auth-Type atrribute in responses" do
    policy = create(:policy)
    policy.responses << create(:response, response_attribute: "Post-Auth-Type", value: "Reject")
    policy.default_accept = false
    policy.save!
    expect(policy.responses.count).to eq(1)
    expect(policy.responses.first.response_attribute).to eq("Post-Auth-Type")
    expect(policy.responses.first.value).to eq("Reject")
  end







=======
>>>>>>> b366b0f78a8898e134fc46b13c6bc27a74af5bac
end
