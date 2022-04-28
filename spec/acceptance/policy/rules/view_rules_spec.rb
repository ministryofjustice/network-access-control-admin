require "rails_helper"

describe "showing a rule", type: :feature do
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when a policy exists with a rule" do
      let!(:policy) { create :policy }
      let!(:rule) { create :rule, policy: }

      it "allows viewing rules on the policy page" do
        visit "/policies/#{policy.id}"

        expect(page).to have_content policy.name
        expect(page).to have_content policy.description
        expect(page).to have_content rule.request_attribute
        expect(page).to have_content rule.operator
        expect(page).to have_content rule.value
      end
    end

    context "when a policy exists without rules" do
      let!(:policy) { create :policy }

      it "does not show the rules table" do
        visit "/policies/#{policy.id}"

        expect(page).to have_content policy.name
        expect(page).to have_content policy.description
        expect(page).to_not have_content "List of rules"
      end
    end
  end
end
