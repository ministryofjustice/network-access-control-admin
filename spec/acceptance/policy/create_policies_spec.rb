require "rails_helper"

describe "create policies", type: :feature do
  context "when the user is a unauthenticated" do
    it "does not allow creating policies" do
      visit "/policies/new"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow creating sites" do
      visit "/policies"

      expect(page).not_to have_content "Create a new policy"

      visit "/policies/new"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "creates a new policy" do
      visit "/policies"

      click_on "Create a new policy"

      expect(current_path).to eql("/policies/new")

      fill_in "Name", with: "My Test Policy"
      fill_in "Description", with: "This is a test policy"

      click_on "Create"

      expect(page).to have_content("Successfully created policy.")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("My Test Policy")

      expect_audit_log_entry_for(editor.email, "create", "Policy")
    end

    it "displays error if form cannot be submitted" do
      visit "/policies/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end
  end
end
