require "rails_helper"

describe "showing a vlan", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing vlans" do
      visit "/vlans/nonexistant-vlan-id"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end
end
