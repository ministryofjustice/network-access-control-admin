require "rails_helper"

describe "update MAC authentication bypasses", type: :feature do
  let!(:mac_authentication_bypass) do
    create(:mac_authentication_bypass)
  end

  context "when the user is unauthenticated" do
    it "does not allow updating bypasses" do
      visit "/mac_authentication_bypasses/#{mac_authentication_bypass.to_param}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing bypasses" do
      visit "/mac_authentication_bypasses"

      expect(page).not_to have_content "Change"

      visit "/mac_authentication_bypasses/#{mac_authentication_bypass.to_param}/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "does update an existing bypass" do
      expect_service_deployment

      visit "/mac_authentication_bypasses/#{mac_authentication_bypass.to_param}"

      first(:link, "Change").click

      expect(page).to have_field("Address", with: mac_authentication_bypass.address)
      expect(page).to have_field("Name", with: mac_authentication_bypass.name)
      expect(page).to have_field("Description", with: mac_authentication_bypass.description)

      fill_in "Address", with: "55:44:33:22:11"

      click_on "Update"

      expect(current_path).to eq("/mac_authentication_bypasses")

      expect(page).to have_content("55:44:33:22:11")
      expect(page).to have_content("Successfully updated MAC authentication bypass.")

      expect_audit_log_entry_for(editor.email, "update", "Mac authentication bypass")
    end
  end
end
