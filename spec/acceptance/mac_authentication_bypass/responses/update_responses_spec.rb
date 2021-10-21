require "rails_helper"

describe "update responses", type: :feature do
  let(:mac_authentication_bypass) { create(:mac_authentication_bypass) }
  let(:response) { create(:mab_response, mac_authentication_bypass: mac_authentication_bypass) }

  context "when the user is unauthenticated" do
    it "does not allow updating responses" do
      visit "/mac_authentication_bypasses/#{mac_authentication_bypass.id}/mab_responses/#{response.id}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing responses" do
      visit "/mac_authentication_bypasses/#{mac_authentication_bypass.id}"

      expect(page).not_to have_content "Edit"

      visit "/mac_authentication_bypasses/#{mac_authentication_bypass.id}/mab_responses/#{response.id}/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      response
    end

    it "does update an existing response" do
      visit "mac_authentication_bypasses/#{mac_authentication_bypass.id}"

      first(:link, "Edit").click

      expect(page).to have_select("response-attribute", text: response.response_attribute)
      expect(page).to have_field("Value", with: response.value)

      select "Tunnel-Type", from: "response-attribute"
      fill_in "Value", with: "8765"

      click_on "Update"

      expect(current_path).to eq("/mac_authentication_bypasses/#{mac_authentication_bypass.id}")

      expect(page).to have_content("Successfully updated response.")
      expect(page).to have_content "Tunnel-Type"
      expect(page).to have_content "8765"

      expect_audit_log_entry_for(editor.email, "update", "Response")
    end
  end
end
