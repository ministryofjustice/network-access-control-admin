require "rails_helper"

describe "showing a MAC authentication bypass", type: :feature do
  before do
    login_as create(:user, :reader)
  end

  context "when the MAC authentication bypasses exists" do
    let!(:mac_authentication_bypass) { create :mac_authentication_bypass, site: create(:site) }

    it "allows viewing bypasses" do
      visit "/mac_authentication_bypasses"

      expect(page).to have_content mac_authentication_bypass.address
      expect(page).to have_content mac_authentication_bypass.name
      expect(page).to have_content mac_authentication_bypass.description
      expect(page).to have_content date_format(mac_authentication_bypass.created_at)
      expect(page).to have_content date_format(mac_authentication_bypass.updated_at)
      expect(page).to have_content mac_authentication_bypass.site.name
    end
  end
end
