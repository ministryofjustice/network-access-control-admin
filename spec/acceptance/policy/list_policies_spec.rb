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
  end
end
