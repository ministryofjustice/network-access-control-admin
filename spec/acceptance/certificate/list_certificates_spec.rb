require "rails_helper"

describe "showing a certificate", type: :feature do
  before do
    login_as create(:user, :reader)
  end

  context "when the certificates exists" do
    let!(:certificate) { create :certificate }

    it "allows viewing certificates" do
      visit "/certificates"

      expect(page).to have_content certificate.name
      expect(page).to have_content certificate.expiry_date
      expect(page).to have_content certificate.filename
      expect(page).to have_content date_format(certificate.created_at)
    end
  end
end
