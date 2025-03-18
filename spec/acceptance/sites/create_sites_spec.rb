require "rails_helper"

describe "create sites", type: :feature do
  context "when the user is a unauthenticated" do
    it "does not allow creating sites" do
      visit "/sites/new"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow creating sites" do
      visit "/sites"

      expect(page).not_to have_content "Create a new site"

      visit "/sites/new"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    # Test to validate the Site Name format 'FITS-XXXX - TYPE - LOCATION'
    it "displays error if site name not in expected format : It should have at least 4 parts separated by dashes" do
      visit "/sites"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      fill_in "Name", with: "FITS-Probation-Maidstone"

      click_on "Create"

      # Site name has to be in the format 'FITS-XXXX-TYPE-LOCATION'
      expect(page).to have_content("The name format is invalid. It should have at least 4 parts separated by dashes")
    end

    it "can create a new site with site name in valid format" do
      visit "/sites"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      fill_in "Name", with: "FITS-9999-Probation-Maidstone"

      click_on "Create"

      expect(page).to have_content("Successfully created site.")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("FITS-9999-Probation-Maidstone")
      expect(page).to have_content("WARNING: Please email InfrastructureAutomationTeam@justice.gov.uk with the FitsID and the client CIDR ranges to be added to the NACs Server Security Group.")
    end

    it "creates a new site with a fallback policy" do
      visit "/sites"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      fill_in "Name", with: "FITS-9999-Probation-Maidstone"

      click_on "Create"

      expect(page).to have_content("Successfully created site.")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).to have_content("FITS-9999-Probation-Maidstone")
      expect(page).to have_content("WARNING: Please email InfrastructureAutomationTeam@justice.gov.uk with the FitsID and the client CIDR ranges to be added to the NACs Server Security Group.")
      expect(page).not_to have_content("There are no fallback policies attached to this site.")

      click_on "FITS-9999-Probation-Maidstone"

      expect(current_path).to eql("/policies/#{Policy.last.id}")
      expect(page).to have_content("Fallback")
      expect(page).to have_content("FITS-9999-Probation-Maidstone")

      expect_audit_log_entry_for(editor.email, "create", "Site")
    end

    it "displays error if form cannot be submitted" do
      visit "/sites/new"

      click_on "Create"

      expect(page).to have_content "There is a problem"
    end
  end
end
