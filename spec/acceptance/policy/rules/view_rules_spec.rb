require "rails_helper"

describe "showing a rule", type: :feature do
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when a policy exists with a rule" do
      let!(:policy) { create :policy }
      let!(:rule) { create :rule, policy: policy }

      it "allows viewing policies" do
        visit "/policies/#{policy.id}"

        expect(page).to have_content policy.name
        expect(page).to have_content policy.description
        expect(page).to have_content rule.request_attribute
        expect(page).to have_content rule.operator
        expect(page).to have_content rule.value
      end
    end
  end
end
