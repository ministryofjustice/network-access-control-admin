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
    let!(:site) { create(:site) }

    before do
      login_as editor
      csv_content = [
        "Address,Description,Responses,Site",
        "aa-bb-cc-dd-ee-ff,some test,Tunnel-Type=VLAN;Reply-Message=Hello to you;Tunnel-ID=777;Tunnel-Type=VLAN;Reply-Message=Hello to you;Tunnel-ID=777,102 Petty France",
      ]
      path = "spec/acceptance/mac_authentication_bypass/dummy_csv/dummy.csv"
      File.open(path, "w+") do |f|
        csv_content.each { |row| f.puts(row) }
      end
    end

    it "imports bypasses" do
      # expect_service_deployment

      visit "/mac_authentication_bypasses"

      click_on "Import bypasses"

      expect(current_path).to eql("/mac_authentication_bypasses_imports/new")

      attach_file("mac_authentication_bypasses_import_bypasses", "spec/acceptance/mac_authentication_bypass/dummy_csv/dummy.csv")
      click_on "Upload"

      expect(page).to have_content("Successfully imported bypasses")
    end
  end
end
