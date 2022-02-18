require "rails_helper"

describe "Export Sites with Clients", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow exporting sites" do
      visit "/sites_export/new"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow exporting sites" do
      visit "/sites"

      expect(page).not_to have_content "Export sites with clients"

      visit "/sites_exports/new"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }
    let!(:site) { create(:site) }
    let!(:first_client) { create(:client, site:) }
    let!(:second_client) { create(:client, site:) }

    before do
      login_as editor
    end

    it "imports sites with clients from a valid CSV" do
      visit "/sites"

      click_on "Export sites with clients"

      expect(current_path).to eql("/sites_exports/new")
      expect(page).to have_text("Export sites with clients")
      expect_any_instance_of(UseCases::CSVExport::SitesWithClients).to receive(:call).once

      click_on "Download CSV"
    end
  end
end
