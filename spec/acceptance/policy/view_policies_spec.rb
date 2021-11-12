require "rails_helper"

describe "showing a policy", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing policies" do
      visit "/policies/nonexistant-policy-id"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when the policy exists" do
      let!(:policy) { create :policy }

      it "allows viewing policies" do
        visit "/policies"

        click_on "View", match: :first

        expect(page).to have_content policy.name
        expect(page).to have_content policy.description
      end
    end

    context "when a policy has rules and responses" do
      let!(:rule) { create :rule }
      let!(:response) { create :response }
      let!(:policy) { create :policy, rules: [rule], responses: [response] }

      it "displays the rules and responses" do
        visit "/policies/#{policy.id}"

        expect(page).to have_content policy.name
        expect(page).to have_content policy.description
        expect(page).to have_content date_format(rule.created_at)
        expect(page).to have_content date_format(rule.updated_at)

        expect(page).to have_content date_format(response.created_at)
        expect(page).to have_content date_format(response.updated_at)
      end
    end
  end
end
