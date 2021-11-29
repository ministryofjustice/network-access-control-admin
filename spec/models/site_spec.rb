require "rails_helper"

RSpec.describe Site, type: :model do
  subject { build :site }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to have_many(:clients) }
  it { is_expected.to have_many(:mac_authentication_bypasses).dependent(:nullify) }
  it { is_expected.to have_many(:site_policy) }
  it { is_expected.to have_many(:policies) }

  it "responds to #fallback_policy" do
    expect(subject.fallback_policy).to be_nil
  end

  it "deletes a fallback policy when a site is deleted" do
    site = create(:site)
    fallback_policy_id = site.fallback_policy.id

    expect(site.fallback_policy).to_not be_nil
    expect(site.fallback_policy.name).to eq("Fallback policy for #{site.name}")
    expect(site.site_policy.where(site_id: site.id, policy_id: fallback_policy_id)).to_not be_nil

    site.destroy!

    expect(Policy.find_by(id: fallback_policy_id)).to be_nil
    expect(site.fallback_policy).to be_nil
    expect(site.site_policy.where(site_id: site.id, policy_id: fallback_policy_id).first).to be_nil
  end

  it "persist and updates the policy count" do
    site = create(:site)
    policy = create(:policy)
    expect(site.policy_count).to eq(1)

    site.policies << policy
    expect(site.policy_count).to eq(2)

    site.assign_attributes(policies: [])
    site.save

    expect(site.policy_count).to eq(0)
  end

  context "when there is a policy with the same name" do
    let!(:policy_with_same_name) { create(:policy, name: "Fallback policy for My site") }

    it "shows an error" do
      site = build(:site, name: "My site")
      expect(site.save).to be false
      expect(site.errors.full_messages_for(:name)).to include("Name Failed to generate fallback policy with error: Name has already been taken")
    end
  end
end
