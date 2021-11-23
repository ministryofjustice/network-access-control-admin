require "rails_helper"

describe "showing a policy", type: :feature do
  before do
    login_as create(:user, :reader)
  end

  context "when policies exist" do
    let!(:policy) { create :policy }

    it "allows viewing policies" do
      visit "/policies"

      expect(page).to have_content policy.name
      expect(page).to have_content policy.description
      expect(page).to have_content date_format(policy.created_at)
      expect(page).to have_content date_format(policy.updated_at)
    end
  end

  context "when there are sites associated with the policy" do
    let!(:policy) { create :policy }

    before do
      4.times { |i| policy.sites << create(:site, name: "Attached site #{i}") }
      create(:site, name: "Some other site")
    end

    it "allows viewing the associated sites" do
      visit "/policies"

      expect(page).to have_content policy.name
      expect(page).to have_content "Sites"
      expect(page).to have_content "4"

      click_on "4"

      expect(current_path).to eq "/sites"
      expect(page).to have_content "Attached site 0"
      expect(page).to have_content "Attached site 1"
      expect(page).to have_content "Attached site 2"
      expect(page).to have_content "Attached site 3"
      expect(page).to_not have_content "Some other site"
    end

    context "ordering" do
      let!(:first_policy) { create(:policy, name: "AA Policy") }
      let!(:second_policy) { create(:policy, name: "BB Policy") }
      let!(:third_policy) { create(:policy, name: "Policy AAA") }

      before do
        visit "/policies"
      end

      it "orders by name" do
        click_on "Name"
        expect(page.text).to match(/AA Policy.*BB Policy/)

        click_on "Name"
        expect(page.text).to match(/BB Policy.*AA Policy/)
      end

      it "orders by updated_at" do
        second_policy.update_attribute(:updated_at, 10.minutes.ago)
        first_policy.update_attribute(:updated_at, 2.minutes.ago)

        click_on "Updated at"
        expect(page.text).to match(/#{date_format(second_policy.updated_at)}.*#{date_format(first_policy.updated_at)}/)

        click_on "Updated at"
        expect(page.text).to match(/#{date_format(first_policy.updated_at)}.*#{date_format(second_policy.updated_at)}/)
      end
    end

    it "paginates" do
      52.times { |t| create(:site, name: "Policy #{t}") }

      visit "/policies"
      expect(page.text).to_not include("Policy 51")
      click_on "2"
      expect(page.text).to include("Policy 51")
    end
  end
end
