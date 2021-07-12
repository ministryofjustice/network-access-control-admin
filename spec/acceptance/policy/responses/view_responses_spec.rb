require "rails_helper"

describe "showing a response", type: :feature do
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when a policy exists with a response" do
      let!(:policy) { create :policy }
      let!(:response) { create :response, policy: policy }

      it "allows viewing responses on the policy page" do
        visit "/policies/#{policy.id}"

        expect(page).to have_content policy.name
        expect(page).to have_content policy.description
        expect(page).to have_content response.response_attribute
        expect(page).to have_content response.value
      end
    end

    context "when a policy exists without responses" do
      let!(:policy) { create :policy }

      it "does not show the responses table" do
        visit "/policies/#{policy.id}"

        expect(page).to have_content policy.name
        expect(page).to have_content policy.description
        expect(page).to_not have_content "List of responses"
      end
    end
  end
end
