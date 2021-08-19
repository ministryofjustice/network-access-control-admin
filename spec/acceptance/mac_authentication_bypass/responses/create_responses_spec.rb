require "rails_helper"

describe "create responses", type: :feature do
  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    after do
      logout
    end

    context "when there is an existing MAC authentication bypass" do
      let!(:mac_authentication_bypass) { create(:mac_authentication_bypass) }

      it "creates a new response" do
        visit "/mac_authentication_bypasses/#{mac_authentication_bypass.id}"

        click_on "Add response"

        expect(page.current_path).to eq(new_mac_authentication_bypass_mab_response_path(mac_authentication_bypass_id: mac_authentication_bypass))

        fill_in "Response attribute", with: "VLAN ID"
        fill_in "Value", with: "1234"

        click_on "Create"

        expect(page).to have_content("Successfully created response.")
        expect(page.current_path).to eq(mac_authentication_bypass_path(id: mac_authentication_bypass.id))
        expect_audit_log_entry_for(editor.email, "create", "Response")
      end

      it "displays error if f cannot be submitted" do
        visit new_mac_authentication_bypass_mab_response_path(mac_authentication_bypass_id: mac_authentication_bypass)

        click_on "Create"

        expect(page).to have_content "There is a problem"
      end
    end
  end
end
