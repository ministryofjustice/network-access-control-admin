require "rails_helper"

describe "searching a MAC authentication bypass", type: :feature do
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when multiple MAC authentication bypass exists" do
      let!(:first_mab) { create :mac_authentication_bypass, address: "aa-11-22-33-44-11", name: "Printer", description: "some printer", created_at: 5.minutes.ago, updated_at: 30.seconds.ago }
      let!(:second_mab) { create :mac_authentication_bypass, address: "bb-11-22-33-44-11", name: "old Phone", description: "so much MAC", created_at: 3.minutes.ago, updated_at: 2.minutes.ago }
      let!(:third_mab) { create :mac_authentication_bypass, address: "cc-11-32-33-44-11", name: "iPhone", description: "my smartphone is not old", created_at: 2.minutes.ago }

      it "allows searching for exact matches" do
        visit "/mac_authentication_bypasses"

        expect(page).to have_content first_mab.address
        expect(page).to have_content first_mab.name
        expect(page).to have_content first_mab.description
        expect(page).to have_content second_mab.address
        expect(page).to have_content second_mab.name
        expect(page).to have_content second_mab.description
        expect(page).to have_content third_mab.address
        expect(page).to have_content third_mab.name
        expect(page).to have_content third_mab.description

        fill_in "search", with: third_mab.address

        click_on "Search"

        expect(page).to have_field("search", with: third_mab.address)

        expect(page).to have_content third_mab.address
        expect(page).to have_content third_mab.name
        expect(page).to have_content third_mab.description

        expect(page).to_not have_content first_mab.address
        expect(page).to_not have_content first_mab.name
        expect(page).to_not have_content first_mab.description
        expect(page).to_not have_content second_mab.address
        expect(page).to_not have_content second_mab.name
        expect(page).to_not have_content second_mab.description

        fill_in "search", with: "11-22"

        click_on "Search"

        expect(page).to have_field("search", with: "11-22")

        expect(page).to have_content first_mab.address
        expect(page).to have_content first_mab.name
        expect(page).to have_content first_mab.description
        expect(page).to have_content second_mab.address
        expect(page).to have_content second_mab.name
        expect(page).to have_content second_mab.description

        expect(page).to_not have_content third_mab.address
        expect(page).to_not have_content third_mab.name
        expect(page).to_not have_content third_mab.description

        fill_in "search", with: "old"

        click_on "Search"

        expect(page).to have_content second_mab.address
        expect(page).to have_content second_mab.name
        expect(page).to have_content second_mab.description
        expect(page).to have_content third_mab.address
        expect(page).to have_content third_mab.name
        expect(page).to have_content third_mab.description

        expect(page).to_not have_content first_mab.address
        expect(page).to_not have_content first_mab.name
        expect(page).to_not have_content first_mab.description
      end

      it "allows ordering search results of MAC Addresses" do
        visit "/mac_authentication_bypasses"

        fill_in "search", with: "11-22"

        click_on "Search"

        click_on "MAC Address"

        within(:xpath, "//table[2]/tbody/tr[1]/td[1]") do
          expect(page).to have_content(first_mab.address)
        end

        expect(page).to_not have_content third_mab.address

        click_on "MAC Address"

        within(:xpath, "//table[2]/tbody/tr[1]/td[1]") do
          expect(page).to have_content(second_mab.address)
        end

        expect(page).to_not have_content third_mab.address
      end

      it "allows ordering search results of MAB names" do
        visit "/mac_authentication_bypasses"

        fill_in "search", with: "Phone"

        click_on "Search"

        click_on "Name"

        within(:xpath, "//table[2]/tbody/tr[1]/td[2]") do
          expect(page).to have_content(third_mab.name)
        end

        expect(page).to_not have_content first_mab.name

        click_on "Name"

        within(:xpath, "//table[2]/tbody/tr[1]/td[2]") do
          expect(page).to have_content(second_mab.name)
        end

        expect(page).to_not have_content first_mab.name
      end

      it "allows ordering search results of MAB description" do
        visit "/mac_authentication_bypasses"

        fill_in "search", with: "so"

        click_on "Search"

        click_on "Description"

        within(:xpath, "//table[2]/tbody/tr[1]/td[3]") do
          expect(page).to have_content(second_mab.description)
        end

        expect(page).to_not have_content third_mab.description

        click_on "Description"

        within(:xpath, "//table[2]/tbody/tr[1]/td[3]") do
          expect(page).to have_content(first_mab.description)
        end

        expect(page).to_not have_content third_mab.description
      end

      it "allows ordering search results of MAB by creation date" do
        visit "/mac_authentication_bypasses"

        fill_in "search", with: "so"

        click_on "Search"

        click_on "Created"

        within(:xpath, "//table[2]/tbody/tr[1]/td[3]") do
          expect(page).to have_content(first_mab.description)
        end

        expect(page).to_not have_content third_mab.description

        click_on "Created"

        within(:xpath, "//table[2]/tbody/tr[1]/td[3]") do
          expect(page).to have_content(second_mab.description)
        end

        expect(page).to_not have_content third_mab.description
      end

      it "allows ordering search results of MAB by update date" do
        visit "/mac_authentication_bypasses"

        fill_in "search", with: "so"

        click_on "Search"

        click_on "Updated"

        within(:xpath, "//table[2]/tbody/tr[1]/td[3]") do
          expect(page).to have_content(second_mab.description)
        end

        expect(page).to_not have_content third_mab.description

        click_on "Updated"

        within(:xpath, "//table[2]/tbody/tr[1]/td[3]") do
          expect(page).to have_content(first_mab.description)
        end

        expect(page).to_not have_content third_mab.description
      end
    end
  end
end
