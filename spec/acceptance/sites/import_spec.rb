require "rails_helper"

describe "Import Sites with Clients", type: :feature do
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

    it "imports sites with clients from a valid CSV" do
      expect_any_instance_of(UseCases::GenerateAuthorisedClients).to receive(:call)
      expect_any_instance_of(UseCases::PublishToS3).to receive(:call)
      expect_service_deployment

      visit "/sites"

      click_on "Import sites with clients"

      expect(current_path).to eql("/sites_import/new")

      attach_file("csv_file", "spec/fixtures/sites_csv/valid.csv")
      click_on "Upload"

      expect(Delayed::Job.last.handler).to match(/job_class: SitesWithClientsImportJob/)
      expect(Delayed::Job.count).to eq(1)
      Delayed::Worker.new.work_off
      byebug
      expect(Delayed::Job.count).to eq(0)

      expect(page).to have_text("Import in progress.. Click here to refresh.")

      click_on "here"

      expect(page.current_path).to eq(sites_import_path(CsvImportResult.last.id))
      expect(page).to have_content("CSV Successfully imported")

      visit "/sites"

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

    xit "can upload CRLF file format" do
      visit "/sites_import/new"

      attach_file("csv_file", "spec/fixtures/sites_csv/valid_crlf.csv")
      click_on "Upload"

      expect(page).to have_content("Successfully imported sites with clients")
    end

    xit "can upload a UTF8_BOM file (Windows support)" do
      visit "/sites_import/new"

      attach_file("csv_file", "spec/fixtures/sites_csv/valid_utf8_bom.csv")
      click_on "Upload"

      expect(page).to have_content("Successfully imported sites with clients")
    end
  end
end
