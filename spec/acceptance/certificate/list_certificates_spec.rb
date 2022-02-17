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
      expect(page).to have_content date_format(certificate.expiry_date)
      expect(page).to have_content certificate.category
      expect(page).to have_content date_format(certificate.created_at)
    end

    context "allows filtering by certificate type" do
      let!(:first_certificate) { create(:certificate, name: "AA Certificate", filename: "server.pem") }
      let!(:second_certificate) { create(:certificate, name: "BB Certificate") }

      before { visit "/certificates" }

      it "filters by server certificate" do
        select "Server", from: "q_filename"

        click_on "Search"

        expect(page).to have_content first_certificate.name
        expect(page).to_not have_content second_certificate.name

        select "Certificate Authority", from: "q_filename"

        click_on "Search"

        expect(page).to have_content second_certificate.name
        expect(page).to_not have_content first_certificate.name

        select "All", from: "q_filename"

        click_on "Search"

        expect(page).to have_content first_certificate.name
        expect(page).to have_content second_certificate.name
      end
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

      it "orders by expiry date" do
        second_certificate.update_attribute(:expiry_date, 10.minutes.ago)
        first_certificate.update_attribute(:expiry_date, 2.minutes.ago)

        click_on "Expiry date"
        expect(page.text).to match(/#{date_format(second_certificate.expiry_date)}.*#{date_format(first_certificate.expiry_date)}/)

        click_on "Expiry date"
        expect(page.text).to match(/#{date_format(first_certificate.expiry_date)}.*#{date_format(second_certificate.expiry_date)}/)
      end

      it "orders by created at" do
        second_certificate.update_attribute(:created_at, 10.minutes.ago)
        first_certificate.update_attribute(:created_at, 2.minutes.ago)

        click_on "Created at"
        expect(page.text).to match(/#{date_format(second_certificate.created_at)}.*#{date_format(first_certificate.created_at)}/)

        click_on "Created at"
        expect(page.text).to match(/#{date_format(first_certificate.created_at)}.*#{date_format(second_certificate.created_at)}/)
      end
    end
  end
end
