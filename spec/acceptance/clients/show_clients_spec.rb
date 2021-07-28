require "rails_helper"

describe "showing a client", type: :feature do
  context "when the user is unauthenticated" do
    let!(:site) { create :site }

    it "does not allow viewing clients" do
      visit "/sites/#{site.id}/clients"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when the client exists" do
      let!(:site) { create :site }
      let!(:client) { create :client, site: site }

      it "allows viewing clients" do
        visit "/sites/#{site.id}clients"

        click_on "View", match: :first

        expect(page).to have_content client.tag
      end
    end
  end
end
