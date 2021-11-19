require "rails_helper"

describe "showing a MAC authentication bypass", type: :feature do
  before do
    login_as create(:user, :reader)
  end

  context "when the MAC authentication bypasses exists" do
    let!(:mac_authentication_bypass) { create :mac_authentication_bypass, name: "Printer 1" }
    let!(:second_mac_authentication_bypass) { create :mac_authentication_bypass, address: "bb-11-22-33-44-11", name: "Printer 2" }

    it "allows viewing bypasses" do
      visit "/mac_authentication_bypasses"

      expect(page).to have_content mac_authentication_bypass.address
      expect(page).to have_content mac_authentication_bypass.name
      expect(page).to have_content mac_authentication_bypass.description
      expect(page).to have_content date_format(mac_authentication_bypass.created_at)
      expect(page).to have_content date_format(mac_authentication_bypass.updated_at)
    end

    it "allows ordering MAC addresses" do
      visit "/mac_authentication_bypasses"

      click_on "MAC Address"

      within(:xpath, "//table[2]/tbody/tr[1]/td[1]") do
        expect(page).to have_content(mac_authentication_bypass.address)
      end

      click_on "MAC Address"

      within(:xpath, "//table[2]/tbody/tr[1]/td[1]") do
        expect(page).to have_content(second_mac_authentication_bypass.address)
      end
    end

    it "allows ordering names" do
      visit "/mac_authentication_bypasses"

      click_on "Name"

      within(:xpath, "//table[2]/tbody/tr[1]/td[2]") do
        expect(page).to have_content(mac_authentication_bypass.name)
      end

      click_on "Name"

      within(:xpath, "//table[2]/tbody/tr[1]/td[2]") do
        expect(page).to have_content(second_mac_authentication_bypass.name)
      end
    end

    it "allows ordering descriptions" do
      visit "/mac_authentication_bypasses"

      click_on "Description"

      within(:xpath, "//table[2]/tbody/tr[1]/td[3]") do
        expect(page).to have_content(mac_authentication_bypass.description)
      end

      click_on "Description"

      within(:xpath, "//table[2]/tbody/tr[1]/td[3]") do
        expect(page).to have_content(second_mac_authentication_bypass.description)
      end
    end

    it "allows ordering created at" do
      visit "/mac_authentication_bypasses"

      click_on "Created"

      within(:xpath, "//table[2]/tbody/tr[1]/td[4]") do
        expect(page).to have_content(date_format(mac_authentication_bypass.created_at))
      end

      click_on "Created"

      within(:xpath, "//table[2]/tbody/tr[1]/td[4]") do
        expect(page).to have_content(date_format(second_mac_authentication_bypass.created_at))
      end
    end

    it "allows ordering updated at" do
      visit "/mac_authentication_bypasses"

      click_on "Updated"

      within(:xpath, "//table[2]/tbody/tr[1]/td[5]") do
        expect(page).to have_content(date_format(mac_authentication_bypass.updated_at))
      end

      click_on "Updated"

      within(:xpath, "//table[2]/tbody/tr[1]/td[5]") do
        expect(page).to have_content(date_format(second_mac_authentication_bypass.updated_at))
      end
    end
  end
end
