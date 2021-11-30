require "rails_helper"

describe "showing a MAC authentication bypass", type: :feature do
  before do
    login_as create(:user, :reader)
  end

  context "when the MAC authentication bypasses exists" do
    let!(:mac_authentication_bypass) { create :mac_authentication_bypass }

    it "allows viewing bypasses" do
      visit "/mac_authentication_bypasses"

      expect(page).to have_content mac_authentication_bypass.address
      expect(page).to have_content mac_authentication_bypass.name
      expect(page).to have_content mac_authentication_bypass.description
      expect(page).to have_content date_format(mac_authentication_bypass.created_at)
      expect(page).to have_content date_format(mac_authentication_bypass.updated_at)
    end
  end

  context "when the MAC authentication bypasses exists with sites" do
    let!(:a_mab) { create :mac_authentication_bypass, address: "aa-11-22-33-44-11", site: create(:site, name: "AAA") }
    let!(:b_mab) { create :mac_authentication_bypass, address: "aa-11-22-33-44-12", site: create(:site, name: "BBB") }

    it "allows ordering bypasses by site names" do
      visit "/mac_authentication_bypasses"

      expect(page).to have_content a_mab.site.name
      expect(page).to have_content b_mab.site.name

      within ".govuk-grid-row" do
        first(:link, "Site").click
      end

      expect(page.text).to match(/#{a_mab.name}.*#{b_mab.name}/)

      within ".govuk-grid-row" do
        first(:link, "Site").click
      end

      expect(page.text).to match(/#{b_mab.name}.*#{a_mab.name}/)
    end
  end
end
