require "rails_helper"

describe "create MAC Authentication Bypasses", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow creating bypasses" do
      visit "/mac_authentication_bypasses/new"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow creating bypasses" do
      visit "/mac_authentication_bypasses"

      expect(page).not_to have_content "Create a new MAC authentication bypass"

      visit "/mac_authentication_bypasses/new"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "creates a new bypass" do
      visit "/mac_authentication_bypasses"

      click_on "Create a new bypass"

      expect(current_path).to eql("/mac_authentication_bypasses/new")

      fill_in "Address", with: "00-11-22-33-55-66"
      fill_in "Name", with: "CCTV"
      fill_in "Description", with: "This is a test bypass"

      click_on "Create"

      expect(page).to have_content("Successfully created MAC authentication bypass.")
      expect(page).to have_content("00-11-22-33-55-66")

      expect_audit_log_entry_for(editor.email, "create", "Mac authentication bypass")
    end

    it "displays error if form cannot be submitted" do
      visit "/mac_authentication_bypasses/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end
  end
end
