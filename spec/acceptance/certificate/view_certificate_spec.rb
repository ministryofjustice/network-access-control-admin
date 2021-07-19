require "rails_helper"

describe "showing a certificate", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing bypasses" do
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
        expect(page).to have_content certificate.description
        expect(page).to have_content certificate.expiry_date
        expect(page).to have_content certificate.subject

      end
    end
  end
end
