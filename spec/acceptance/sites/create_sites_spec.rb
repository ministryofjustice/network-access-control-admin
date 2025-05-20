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
    end

    # Test to validate the Site Name format 'FITS-XXXX-TYPE-LOCATION' when it starts with 'FITS'
    it "displays error if the site name starts with 'FITS' but does not follow the expected format" do
      visit "/sites"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      fill_in "Name", with: "FITS-1234-InvalidName"

      click_on "Create"

      expect(page).to have_content("The name format is invalid. It should have at least 4 parts separated by dashes")
    end

    # Test to validate the Site Name format 'MOJO-XXXX-TYPE-LOCATION' when it starts with 'MOJO'
    it "displays error if the site name starts with 'MOJO' but does not follow the expected format" do
      visit "/sites"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      fill_in "Name", with: "MOJO-1234-InvalidName"

      click_on "Create"

      # Error message should indicate invalid format
      expect(page).to have_content("The name format is invalid. It should have at least 4 parts separated by dashes")
    end

    # Test that a valid MOJO name format is accepted
    it "creates a site with a valid 'MOJO' name format" do
      visit "/sites"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      fill_in "Name", with: "MOJO-9999-Probation-Maidstone"

      click_on "Create"

      expect(page).to have_content("Successfully created site.")
      expect(page).to have_content("MOJO-9999-Probation-Maidstone")
    end

    # Test that the name is automatically enforced to uppercase if the name starts with 'FITS' or 'MOJO'
    it "enforces uppercase on the site name if it starts with 'FITS'" do
      visit "/sites"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      fill_in "Name", with: "fits-9999-Probation-Maidstone"

      click_on "Create"

      expect(page).to have_content("Suggested Name: 'FITS-9999-Probation-Maidstone'. Please confirm if this is acceptable.")
    end

    it "enforces uppercase on the site name if it starts with 'MOJO'" do
      visit "/sites"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      fill_in "Name", with: "mojo-9999-Probation-Maidstone"

      click_on "Create"

      expect(page).to have_content("Suggested Name: 'MOJO-9999-Probation-Maidstone'. Please confirm if this is acceptable.")
    end

    # Test that the name is automatically enforced to strip whitespaces and replace them with dashes
    it "enforces whitespace striping" do
      visit "/sites"

      click_on "Create a new site"

      expect(current_path).to eql("/sites/new")

      fill_in "Name", with: "FITS-1234-Probation-London Camberly"

      click_on "Create"

      expect(page).to have_content("Suggested Name: 'FITS-1234-Probation-London_Camberly'. Please confirm if this is acceptable.")
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
