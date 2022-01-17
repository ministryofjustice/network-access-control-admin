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
      expect(page).to have_content certificate.category
      expect(page).to have_content date_format(certificate.created_at)
    end

    context "when ordering" do
      let!(:first_certificate) { create(:certificate, name: "AA Certificate") }
      let!(:second_certificate) { create(:certificate, name: "BB Certificate") }
      let!(:third_certificate) { create(:certificate, name: "CC Certificate") }

      before do
        visit "/certificates"
      end

      it "orders by name" do
        click_on "Name"
        expect(page.text).to match(/AA Certificate.*BB Certificate/)

        click_on "Name"
        expect(page.text).to match(/BB Certificate.*AA Certificate/)
      end

      it "orders by category" do
        second_certificate.update_attribute(:category, "EAP")
        first_certificate.update_attribute(:category, "RADSEC")

        click_on "Category"
        expect(page.text).to match(/EAP.*RADSEC/)

        click_on "Category"
        expect(page.text).to match(/RADSEC.*EAP/)
      end
    end
  end
end
