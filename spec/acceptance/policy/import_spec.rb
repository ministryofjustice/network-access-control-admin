require "rails_helper"

describe "Import Policies", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow importing policies" do
      visit "/policies_import/new"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow importing sites" do
      visit "/policies"

      expect(page).not_to have_content "Import policies"

      visit "/policies_imports/new"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end
end
