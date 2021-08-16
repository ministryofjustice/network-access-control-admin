require "rails_helper"

describe Forms::SitePoliciesForm, type: :model do
  describe "#build_from_site" do
    it "creates an object based on the site model" do
      policiy = build(:policy)
      site = build_stubbed(:site, policies: [policiy])
      form = Forms::SitePoliciesForm.build_from_site(site)

      expect(form.policies).to eq([policiy])
    end
  end

  describe "#save" do
    let(:site) { create(:site) }

    context "when there is one fallback policy" do
      let(:policy) { create(:policy, fallback: true) }

      it "saves the policies on the site and returns true" do
        form = Forms::SitePoliciesForm.new(policies: [policy])

        expect(form.save(site)).to be_truthy
        expect(site.policies).to eq([policy])
      end
    end

    context "when there are multiple fallback policies" do
      let(:first_fallback_policy) { create(:policy, fallback: true) }
      let(:second_fallback_policy) { create(:policy, fallback: true) }

      it "does not save the policies on the site and returns false" do
        form = Forms::SitePoliciesForm.new(policies: [first_fallback_policy, second_fallback_policy])

        expect(form.save(site)).to be_falsey
        expect(site.policies).to eq([])
      end
    end
  end
end
