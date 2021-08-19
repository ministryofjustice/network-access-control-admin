require "rails_helper"

describe "delete responses", type: :feature do
  context "when the user is a viewer" do
    let!(:mac_authentication_bypass) { create(:mac_authentication_bypass) }

    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting responses" do
      visit "/mac_authentication_bypasses/#{mac_authentication_bypass.id}"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    context "when there is an existing MAC authentication bypass with a response" do
      let!(:mac_authentication_bypass) { create(:mac_authentication_bypass) }
      let!(:response) { create(:mab_response, mac_authentication_bypass: mac_authentication_bypass) }

      it "does delete an existing response" do
        visit "/mac_authentication_bypasses/#{mac_authentication_bypass.id}"

        click_on "Delete"

        expect(page).to have_content("Are you sure you want to delete this response?")
        expect(page).to have_content("#{response.response_attribute}: #{response.value}")

        click_on "Delete response"

        expect(current_path).to eq("/mac_authentication_bypasses/#{mac_authentication_bypass.id}")
        expect(page).to have_content("Successfully deleted response.")
        expect(page).not_to have_content(response.response_attribute)
        expect(page).not_to have_content(response.value)

        expect_audit_log_entry_for(editor.email, "destroy", "Response")
      end
    end
  end
end
