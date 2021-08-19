require "rails_helper"

describe "showing a response", type: :feature do
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when a MAC authentication bypass exists with a response" do
      let!(:mac_authentication_bypass) { create :mac_authentication_bypass }
      let!(:response) { create :mab_response, mac_authentication_bypass: mac_authentication_bypass }

      it "allows viewing responses on the MAC authentication bypass page" do
        visit "/mac_authentication_bypasses/#{mac_authentication_bypass.id}"

        expect(page).to have_content mac_authentication_bypass.address
        expect(page).to have_content mac_authentication_bypass.name
        expect(page).to have_content mac_authentication_bypass.description
        expect(page).to have_content response.response_attribute
        expect(page).to have_content response.value
      end
    end

    context "when a MAC authentication bypass exists without responses" do
      let!(:mac_authentication_bypass) { create :mac_authentication_bypass }

      it "does not show the responses table" do
        visit "/mac_authentication_bypasses/#{mac_authentication_bypass.id}"

        expect(page).to have_content mac_authentication_bypass.address
        expect(page).to have_content mac_authentication_bypass.name
        expect(page).to have_content mac_authentication_bypass.description
        expect(page).to_not have_content "List of responses"
      end
    end
  end
end
