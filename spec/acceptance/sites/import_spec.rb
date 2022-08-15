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

      visit "/sites_imports/new"

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

      expect(current_path).to eql("/sites_imports/new")

      attach_file("csv_file", "spec/fixtures/sites_csv/valid.csv")
      click_on "Upload"

      expect(Delayed::Job.last.handler).to match(/job_class: SitesWithClientsImportJob/)
      expect(Delayed::Job.count).to eq(1)
      Delayed::Worker.new.work_off
      expect(Delayed::Job.count).to eq(0)

      expect(page).to have_text("Import is in progress, please wait...")
      expect(page).to have_text("Click here to refresh.")

      click_on "here"

      expect(page.current_path).to eq(sites_import_path(CsvImportResult.last.id))
      expect(page).to have_content("CSV successfully imported!")

      visit "/sites"

      expect(page).to have_content("Site 1")
      expect(page).to have_content("Site 2")
      expect(page).to have_content("Site 3")

      visit "/sites/#{Site.first.id}"

      expect(page).to have_content("127.1.1.1/32")
      expect(page).to have_content("128.1.1.1/32")
      expect(page).to have_content("Test Policy 1")

      within "#site-policy-priority-#{Site.first.policies.first.id}" do
        expect(page).to have_content("10")
      end

      click_on "Fallback policy for Site 1"

      expect(page).to have_content("Action")
      expect(page).to have_content("Accept")
      expect(page).to have_content("Dlink-VLAN-ID")
      expect(page).to have_content("888")
      expect(page).to have_content("Reply-Message")
      expect(page).to have_content("hi")

      visit "/sites/#{Site.second.id}"

      expect(page).to have_content("127.2.2.2/32")
      expect(page).to have_content("128.2.2.2/32")
      expect(page).to have_content("Test Policy 2")

      click_on "Fallback policy for Site 2"

      expect(page).to have_content("Action")
      expect(page).to have_content("Accept")
      expect(page).to have_content("Dlink-VLAN-ID")
      expect(page).to have_content("888")
      expect(page).to have_content("Reply-Message")
      expect(page).to have_content("hi")

      visit "/sites/#{Site.third.id}"

      expect(page).to have_content("126.3.3.3/32")
      expect(page).to have_content("127.3.3.3/32")
      expect(page).to have_content("128.4.4.4/32")
      expect(page).to have_content("Test Policy 1")

      within "#site-policy-priority-#{Site.third.policies.first.id}" do
        expect(page).to have_content("10")
      end

      expect(page).to have_content("Test Policy 2")

      within "#site-policy-priority-#{Site.third.policies.second.id}" do
        expect(page).to have_content("20")
      end

      expect(page).to have_content("Fallback policy for Site 3")

      click_on "Fallback policy for Site 3"

      expect(page).to have_content("Post-Auth-Type")
      expect(page).to have_content("Reject")

      expect_audit_log_entry_for(editor.email, "create", "Site")
      expect_audit_log_entry_for(editor.email, "create", "Site policy")
      expect_audit_log_entry_for(editor.email, "create", "Client")
    end

    it "can upload CRLF file format" do
      visit "/sites_imports/new"

      attach_file("csv_file", "spec/fixtures/sites_csv/valid_crlf.csv")
      click_on "Upload"

      expect(page).to have_content("Importing sites with clients")

      Delayed::Worker.new.work_off

      visit "/sites"

      expect(page).to have_content("Site 1")
    end

    it "can upload a UTF8_BOM file (Windows support)" do
      visit "/sites_imports/new"

      attach_file("csv_file", "spec/fixtures/sites_csv/valid_utf8_bom.csv")
      click_on "Upload"

      expect(page).to have_content("Importing sites with clients")

      Delayed::Worker.new.work_off

      visit "/sites"

      expect(page).to have_content("Site 1")
    end

    it "shows errors when the CSV is invalid" do
      visit "/sites"

      click_on "Import sites with clients"

      attach_file("csv_file", "spec/fixtures/sites_csv/invalid.csv")
      click_on "Upload"

      expect(current_path).to eql(sites_import_path(CsvImportResult.first.id))

      Delayed::Worker.new.work_off

      click_on "here"

      expect(page).to have_content("There is a problem")

      expect(page).to have_content("Duplicate Site name \"Site 1\" found in CSV")
      expect(page).to have_content("Overlapping RADIUS Clients IP ranges \"127.1.1.1\" - \"127.1.1.1\"")
    end

    it "shows errors when the use-case returns an unexpected error" do
      allow_any_instance_of(UseCases::CSVImport::SitesWithClients).to receive(:call).and_raise("something bad")

      visit "/sites"

      click_on "Import sites with clients"

      attach_file("csv_file", "spec/fixtures/sites_csv/invalid.csv")
      click_on "Upload"

      expect(current_path).to eql(sites_import_path(CsvImportResult.first.id))

      Delayed::Worker.new.work_off

      click_on "here"

      expect(page).to have_content("There is a problem")

      expect(page).to have_content("Error while importing data from CSV: something bad")
    end
  end
end
