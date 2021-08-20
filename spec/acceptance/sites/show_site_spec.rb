require "rails_helper"

describe "showing a site", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing sites" do
      visit "/sites/nonexistant-site-id"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when the site exists" do
      let!(:site) { create :site, name: "Yusuf's brilliant site" }

      it "allows viewing sites" do
        visit "/sites"

        click_on "View", match: :first

        expect(page).to have_content site.name
        expect(page).to have_content "yusuf_s_brilliant_site"
      end
    end
  end
end
