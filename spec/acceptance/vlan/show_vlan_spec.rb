require "rails_helper"

describe "showing a vlan", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing vlans" do
      visit "/vlans/nonexistant-vlan-id"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when the vlan exists" do
      let!(:vlan) { create :vlan }

      it "allows viewing vlans" do
        visit "/vlans"

        click_on "View", match: :first

        expect(page).to have_content vlan.name
      end
    end
  end
end
