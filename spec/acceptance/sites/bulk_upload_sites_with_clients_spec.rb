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
      create(:policy, name: "Test Policy 1")
      create(:policy, name: "Test Policy 2")

      login_as editor
    end

    it "shows errors when the CSV is missing" do
      visit "/sites"

      click_on "Import sites with clients"

      expect(current_path).to eql("/sites_import/new")

      click_on "Upload"

      expect(page).to have_content("CSV is missing")
    end

    it "imports sites with clients from a valid CSV" do
      expect_service_deployment

      visit "/sites"

      click_on "Import sites with clients"

      expect(current_path).to eql("/sites_import/new")

      attach_file("csv_file", "spec/fixtures/sites_csv/valid.csv")
      click_on "Upload"

      expect(current_path).to eql("/sites")
      expect(page).to have_content("Successfully imported sites with clients")

      expect(page).to have_content("Site 1")
      expect(page).to have_content("Site 2")
      expect(page).to have_content("Site 3")

      visit "/sites/#{Site.first.id}"

      expect(page).to have_content("127.1.1.1/32")
      expect(page).to have_content("128.1.1.1/32")
      expect(page).to have_content("Test Policy 1")

      click_on "Fallback policy for Site 1"

      expect(page).to have_content("Dlink-VLAN-ID")
      expect(page).to have_content("888")
      expect(page).to have_content("Reply-Message")
      expect(page).to have_content("hi")

      visit "/sites/#{Site.second.id}"

      expect(page).to have_content("127.2.2.2/32")
      expect(page).to have_content("128.2.2.2/32")
      expect(page).to have_content("Test Policy 2")

      click_on "Fallback policy for Site 2"

      expect(page).to have_content("Dlink-VLAN-ID")
      expect(page).to have_content("888")
      expect(page).to have_content("Reply-Message")
      expect(page).to have_content("hi")

      visit "/sites/#{Site.third.id}"

      expect(page).to have_content("126.3.3.3/32")
      expect(page).to have_content("127.3.3.3/32")
      expect(page).to have_content("128.4.4.4/32")
      expect(page).to have_content("Test Policy 1")
      expect(page).to have_content("Test Policy 2")
      expect(page).to have_content("Fallback policy for Site 3")
    end

    it "can upload CRLF file format" do
      visit "/sites_import/new"

      attach_file("csv_file", "spec/fixtures/sites_csv/valid_crlf.csv")
      click_on "Upload"

      expect(page).to have_content("Successfully imported sites with clients")
    end

    it "can upload a UTF8_BOM file (Windows support)" do
      visit "/sites_import/new"

      attach_file("csv_file", "spec/fixtures/sites_csv/valid_utf8_bom.csv")
      click_on "Upload"

      expect(page).to have_content("Successfully imported sites with clients")
    end
  end
end
