require "rails_helper"

describe "listing sites", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing sites" do
      visit "/sites"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when sites exists" do
      let!(:site) { create :site, name: "Your brilliant site" }

      it "allows viewing sites" do
        visit "/sites"

        expect(page).to have_content site.name
        expect(page).to have_content date_format(site.created_at)
        expect(page).to have_content date_format(site.updated_at)
      end
    end
  end
end
