require "rails_helper"

describe "bulk upload Sites with Clients", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow importing sites" do
      visit "/sites_import/new"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow importing sites" do
      visit "/sites"

      expect(page).not_to have_content "Import sites with clients"

      visit "/sites_import/new"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "shows errors when the CSV is missing" do
      visit "/sites"

      click_on "Import sites with clients"

      expect(current_path).to eql("/sites_import/new")

      click_on "Upload"

      expect(page).to have_content("CSV is missing")
    end
  end
end
