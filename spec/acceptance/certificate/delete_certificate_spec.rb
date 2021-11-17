require "rails_helper"

describe "delete certificates", type: :feature do
  let!(:certificate) do
    create(:certificate)
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting certificates" do
      visit "/certificates/#{certificate.id}"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "does delete a certificate" do
      visit "/certificates/#{certificate.id}"

      click_on "Delete"

      expect(page).to have_content("Are you sure you want to delete this certificate?")
      expect(page).to have_content(certificate.name)
      expect(page).to have_content(certificate.description)
      expect(page).to have_content(certificate.subject)
      expect(page).to have_content(certificate.expiry_date)

      click_on "Delete certificate"

      expect(current_path).to eq("/certificates")
      expect(page).to have_content("Successfully deleted certificate.")
      expect(page).not_to have_content(certificate.name)

      expect_audit_log_entry_for(editor.email, "destroy", "Certificate")
    end
  end
end
