require "rails_helper"

describe "create certificates", type: :feature do
  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "uploads a new certificate" do
      visit "/certificates"

      click_on "Upload a new certificate"

      expect(current_path).to eql("/certificates/new")

      fill_in "Name", with: "My Test Certificate"
      fill_in "Description", with: "My test certificate description details"
      attach_file("Certificate", "spec/acceptance/certificate/dummy_certificate/mytestcertificate.pem")

      click_on "Upload"

      # TODO: assert for calling publish certificate use-case
      # expect(UseCases::PublishCertificate).to have_received(:execute).with(certificate: certificate)

      expect(page).to have_content("Successfully uploaded certificate.")
      expect(page).to have_content("My Test Certificate")

      expect_audit_log_entry_for(editor.email, "create", "Certificate")
    end

    it "displays error if form cannot be submitted" do
      visit "/certificates/new"

      click_on "Upload"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "Description can't be blank"
      expect(page).to have_content "Name can't be blank"
      expect(page).to have_content "Certificate is missing or invalid"
      expect(page).to_not have_content "Expiry date can't be blank"
      expect(page).to_not have_content "Subject can't be blank"
    end
  end
end
