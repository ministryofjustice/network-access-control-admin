require "rails_helper"

describe "showing a MAC authentication bypass", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing bypasses" do
      visit "/mac_authentication_bypasses"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when the MAC authentication bypass exists" do
      let!(:mac_authentication_bypass) { create :mac_authentication_bypass }

      it "allows viewing bypasses" do
        visit "/mac_authentication_bypasses"

        expect(page).to have_content mac_authentication_bypass.address
        expect(page).to have_content mac_authentication_bypass.name
        expect(page).to have_content mac_authentication_bypass.description
      end
    end
  end
end
