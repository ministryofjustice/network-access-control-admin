require "rails_helper"

describe "showing a certificate", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing certificates" do
      visit "/certificates"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when the certificate exists" do
      let!(:certificate) { create :certificate }

      it "allows viewing certificates" do
        visit "/certificates"

        expect(page).to have_content certificate.name
        expect(page).to have_content certificate.category
        expect(page).to have_content date_format(certificate.expiry_date)
      end

      it "allows viewing the details of a certificate" do
        visit "/certificates/#{certificate.id}"

        expect(page).to have_content certificate.name
        expect(page).to have_content certificate.category
        expect(page).to have_content date_format(certificate.expiry_date)
        expect(page).to have_content certificate.subject
        expect(page).to have_content certificate.issuer
        expect(page).to have_content certificate.serial
        expect(page).to have_content certificate.extensions
      end
    end

    context "when a certificate exists but is out of date" do
      let!(:certificate) { create :certificate }

      it "shows a banner which notifies the user that a certificate is out of date" do
        visit root_path
        expect(page).to have_content "123123123123."
      end
    end
  end
end
