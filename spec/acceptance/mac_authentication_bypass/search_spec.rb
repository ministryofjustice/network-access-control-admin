require "rails_helper"

describe "searching a MAC authentication bypass", type: :feature do
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when multiple MAC authentication bypass exists" do
      let!(:first_mab) { create :mac_authentication_bypass, address: "aa-11-22-33-44-11" }
      let!(:second_mab) { create :mac_authentication_bypass, address: "bb-11-22-33-44-11" }
      let!(:third_mab) { create :mac_authentication_bypass, address: "cc-11-32-33-44-11" }

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

        expect(page).to have_content first_mab.address
        expect(page).to have_content first_mab.name
        expect(page).to have_content first_mab.description
        expect(page).to have_content second_mab.address
        expect(page).to have_content second_mab.name
        expect(page).to have_content second_mab.description

        expect(page).to_not have_content third_mab.address
        expect(page).to_not have_content third_mab.name
        expect(page).to_not have_content third_mab.description
      end
    end
  end
end
