require "rails_helper"

describe "bulk upload MAC Authentication Bypasses", type: :feature do
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
      # expect_service_deployment

      visit "/mac_authentication_bypasses"

      click_on "Import bypasses"

      expect(current_path).to eql("/mac_authentication_bypasses_imports/new")

      attach_file("mac_authentication_bypasses_import_bypasses", "spec/fixtures/mac_authentication_bypasses_csv/valid.csv")
      click_on "Upload"

      expect(page).to have_content("Confirm upload")
      expect(page).to have_content("aa-bb-cc-dd-ee-ff")
      expect(page).to have_content("some printer")
      expect(page).to have_content("some test")
      expect(page).to have_content("102 Petty France")

      click_on "Confirm Upload"

      expect(current_path).to eql("/mac_authentication_bypasses")
      expect(page).to have_content("Successfully imported bypasses")
    end
  end
end
