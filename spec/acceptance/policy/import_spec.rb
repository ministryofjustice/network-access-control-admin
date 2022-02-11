require "rails_helper"

describe "Import Policies", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow importing policies" do
      visit "/policies_import/new"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow importing sites" do
      visit "/policies"

      expect(page).not_to have_content "Import policies"

      visit "/policies_imports/new"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "imports policies from a valid CSV" do
      visit "/policies"

      click_on "Import policies"

      expect(current_path).to eql("/policies_imports/new")

      attach_file("csv_file", "spec/fixtures/policies_csv/valid.csv")

      click_on "Upload"

      expect(Delayed::Job.last.handler).to match(/job_class: PolicyImportJob/)
      expect(Delayed::Job.count).to eq(1)
      Delayed::Worker.new.work_off
      expect(Delayed::Job.count).to eq(0)

      expect(CsvImportResult.all.count).to eq(1)
      expect(CsvImportResult.first.errors).to be_empty

      expect(page).to have_text("Import in progress...")
      expect(page).to have_text("Click here to refresh.")

      click_on "here"

      expect(page.current_path).to eq(policies_import_path(CsvImportResult.last.id))
      expect(page).to have_content("CSV Successfully imported")

      visit "/policies"

      expect(page).to have_content("MOJO_LAN_VLAN101")
      expect(page).to have_content("Some description")
      expect(page).to have_content("MOJO_LAN_VLAN202")
      expect(page).to have_content("Some description2")

      visit "/policies/#{Policy.first.id}"

      expect(page).to have_content("TLS-Cert-Common-Name")
      expect(page).to have_content("contains")
      expect(page).to have_content("hihi")
      expect(page).to have_content("User-Name")
      expect(page).to have_content("equals")
      expect(page).to have_content("Bob")

      expect(page).to have_content("Tunnel-Type")
      expect(page).to have_content("VLAN")
      expect(page).to have_content("Reply-Message")
      expect(page).to have_content("Hello to you")

      visit "/policies/#{Policy.last.id}"

      expect(page).to have_content("TLS-Cert-Common-Name")
      expect(page).to have_content("contains")
      expect(page).to have_content("hihi2")
      expect(page).to have_content("User-Name")
      expect(page).to have_content("equals")
      expect(page).to have_content("Bob2")

      expect(page).to have_content("Tunnel-Type")
      expect(page).to have_content("VLAN")
      expect(page).to have_content("Reply-Message")
      expect(page).to have_content("Bye to you")

      expect_audit_log_entry_for(editor.email, "create", "Policy")
      expect_audit_log_entry_for(editor.email, "create", "Rule")
      expect_audit_log_entry_for(editor.email, "create", "Response")
    end

    it "can upload CRLF file format" do
      visit "/policies"

      click_on "Import policies"

      expect(current_path).to eql("/policies_imports/new")

      attach_file("csv_file", "spec/fixtures/policies_csv/valid_crlf.csv")
      click_on "Upload"

      expect(page).to have_content("Importing policies")

      Delayed::Worker.new.work_off

      visit "/policies"

      expect(page).to have_content("MOJO_LAN_VLAN101")
      expect(page).to have_content("Some description")
    end

    it "can upload a UTF8_BOM file (Windows support)" do
      visit "/policies"

      click_on "Import policies"

      expect(current_path).to eql("/policies_imports/new")

      attach_file("csv_file", "spec/fixtures/policies_csv/valid_utf8_bom.csv")
      click_on "Upload"

      expect(page).to have_content("Importing policies")

      Delayed::Worker.new.work_off

      visit "/policies"

      expect(page).to have_content("MOJO_LAN_VLAN101")
      expect(page).to have_content("Some description")
    end

    it "shows errors when the CSV is invalid" do
      visit "/policies"

      click_on "Import policies"

      expect(current_path).to eql(new_policies_import_path)

      attach_file("csv_file", "spec/fixtures/policies_csv/invalid.csv")
      click_on "Upload"

      expect(current_path).to eql(policies_import_path(CsvImportResult.first.id))

      Delayed::Worker.new.work_off

      click_on "here"

      expect(page).to have_content("There is a problem")

      expect(page).to have_content("Error on row 3: Rules is invalid")
      expect(page).to have_content("Error on row 3: Unknown attribute 'Invalid-Attribute'")
    end

    it "shows errors when the use-case returns an unexpected error" do
      allow_any_instance_of(UseCases::CSVImport::Policies).to receive(:call).and_raise("something bad")

      visit "/policies"

      click_on "Import policies"

      attach_file("csv_file", "spec/fixtures/policies_csv/invalid.csv")
      click_on "Upload"

      expect(current_path).to eql(policies_import_path(CsvImportResult.first.id))

      Delayed::Worker.new.work_off

      click_on "here"

      expect(page).to have_content("There is a problem")

      expect(page).to have_content("Error while importing data from CSV: something bad")
    end
  end
end
