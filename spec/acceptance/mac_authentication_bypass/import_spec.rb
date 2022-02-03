require "rails_helper"

describe "Import MAC Authentication Bypasses", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow importing bypasses" do
      visit "/mac_authentication_bypasses_imports/new"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow importing bypasses" do
      visit "/mac_authentication_bypasses/"

      expect(page).not_to have_content "Import bypasess"

      visit "/mac_authentication_bypasses_imports/new"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }
    let!(:site) { create(:site, name: "102 Petty France") }

    before do
      login_as editor
    end

    it "imports bypasses from a valid CSV" do
      expect_any_instance_of(UseCases::GenerateAuthorisedMacs).to receive(:call)
      expect_any_instance_of(UseCases::PublishToS3).to receive(:call)
      expect_service_deployment

      visit "/mac_authentication_bypasses"

      click_on "Import bypasses"

      expect(current_path).to eql("/mac_authentication_bypasses_imports/new")

      attach_file("csv_file", "spec/fixtures/mac_authentication_bypasses_csv/valid.csv")
      click_on "Upload"

      expect(Delayed::Job.last.handler).to match(/job_class: MacAuthenticationBypassImportJob/)
      expect(Delayed::Job.count).to eq(1)
      Delayed::Worker.new.work_off
      expect(Delayed::Job.count).to eq(0)

      expect(CsvImportResult.all.count).to eq(1)
      expect(CsvImportResult.first.errors).to be_empty

      expect(page).to have_text("Import in progress.. Click here to refresh.")

      click_on "here"

      expect(page.current_path).to eq(mac_authentication_bypasses_import_path(CsvImportResult.last.id))
      expect(page).to have_content("CSV Successfully imported")

      visit "/mac_authentication_bypasses"

      expect(page).to have_content("aa-bb-cc-dd-ee-ff")
      expect(page).to have_content("printer1")
      expect(page).to have_content("some test1")

      expect(page).to have_content("aa-bb-cc-ff-ee-ff")
      expect(page).to have_content("printer2")
      expect(page).to have_content("some test2")

      expect(page).to have_content("aa-bb-ff-dd-ee-ff")
      expect(page).to have_content("printer3")
      expect(page).to have_content("some test3")
      expect(page).to have_content("102 Petty France")

      visit "/mac_authentication_bypasses/#{MacAuthenticationBypass.first.id}"

      expect(page).to have_content("Tunnel-Type")
      expect(page).to have_content("VLAN")
      expect(page).to have_content("Reply-Message")
      expect(page).to have_content("Hello to you")
      expect(page).to have_content("SG-Tunnel-Id")
      expect(page).to have_content("777")

      visit "/mac_authentication_bypasses/#{MacAuthenticationBypass.second.id}"

      expect(page).to have_content("Tunnel-Type")
      expect(page).to have_content("VLAN")
      expect(page).to have_content("Reply-Message")
      expect(page).to have_content("Hello to you")
      expect(page).to have_content("SG-Tunnel-Id")
      expect(page).to have_content("888")

      visit "/mac_authentication_bypasses/#{MacAuthenticationBypass.third.id}"

      expect(page).to have_content("Tunnel-Type")
      expect(page).to have_content("VLAN")
      expect(page).to have_content("Reply-Message")
      expect(page).to have_content("Hello to you")
      expect(page).to have_content("SG-Tunnel-Id")
      expect(page).to have_content("999")

      expect_audit_log_entry_for(editor.email, "create", "Mac authentication bypass")
      expect_audit_log_entry_for(editor.email, "create", "Response")
    end

    it "can upload CRLF file format" do
      visit "/mac_authentication_bypasses"

      click_on "Import bypasses"

      expect(current_path).to eql("/mac_authentication_bypasses_imports/new")

      attach_file("csv_file", "spec/fixtures/mac_authentication_bypasses_csv/valid_crlf.csv")
      click_on "Upload"

      expect(page).to have_content("Importing MAC addresses")

      Delayed::Worker.new.work_off

      visit "/mac_authentication_bypasses"

      expect(page).to have_content("aa-bb-cc-dd-ee-ff")
      expect(page).to have_content("printer1")
      expect(page).to have_content("some test1")
    end

    it "can upload a UTF8_BOM file (Windows support)" do
      visit "/mac_authentication_bypasses"

      click_on "Import bypasses"

      expect(current_path).to eql("/mac_authentication_bypasses_imports/new")

      attach_file("csv_file", "spec/fixtures/mac_authentication_bypasses_csv/valid_utf8_bom.csv")
      click_on "Upload"

      expect(page).to have_content("Importing MAC addresses")

      Delayed::Worker.new.work_off

      visit "/mac_authentication_bypasses"

      expect(page).to have_content("aa-bb-cc-dd-ee-ff")
      expect(page).to have_content("printer1")
      expect(page).to have_content("some test1")
    end

    it "shows errors when the CSV is invalid" do
      visit "/mac_authentication_bypasses"

      click_on "Import bypasses"

      expect(current_path).to eql(new_mac_authentication_bypasses_import_path)

      attach_file("csv_file", "spec/fixtures/mac_authentication_bypasses_csv/invalid.csv")
      click_on "Upload"

      expect(current_path).to eql(mac_authentication_bypasses_import_path(CsvImportResult.first.id))

      Delayed::Worker.new.work_off

      click_on "here"

      expect(page).to_not have_content("Valid Printer")

      expect(page).to have_content("There is a problem")

      expect(page).to have_content("Error on row 2: Address is invalid")
      expect(page).to have_content("Site \"Unknown Site\" is not found")
    end
  end
end
