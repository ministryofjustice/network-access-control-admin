require "rails_helper"

describe "delete MAC authentication bypasses", type: :feature do
  let!(:mac_authentication_bypass) do
    create(:mac_authentication_bypass)
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting bypasses" do
      visit "/mac_authentication_bypasses/#{mac_authentication_bypass.id}"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "does delete a MAC address" do
      expect_service_deployment

      visit "/mac_authentication_bypasses/#{mac_authentication_bypass.id}"

      click_on "Delete"

      expect(page).to have_content("Are you sure you want to delete this MAC authentication bypass?")
      expect(page).to have_content(mac_authentication_bypass.address)
      expect(page).to have_content(mac_authentication_bypass.name)
      expect(page).to have_content(mac_authentication_bypass.description)

      click_on "Delete bypass"

      expect(current_path).to eq("/mac_authentication_bypasses")
      expect(page).to have_content("Successfully deleted MAC authentication bypass.")
      expect(page).not_to have_content(mac_authentication_bypass.address)

      expect_audit_log_entry_for(editor.email, "destroy", "Mac authentication bypass")
    end
  end
end
