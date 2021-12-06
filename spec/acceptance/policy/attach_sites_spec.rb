require "rails_helper"

describe "attach sites to a policy", type: :feature do
  context "when the user is a reader" do
    before do
      login_as create(:user, :reader)
    end

    context "when both site and policy exists" do
      let!(:site) { create :site }
      let!(:policy) { create :policy }

      it "does not allow attaching policies to a site" do
        visit "/policies"

        click_on "View", match: :first

        expect(page).to_not have_content "Manage sites"
      end
    end
  end
end
