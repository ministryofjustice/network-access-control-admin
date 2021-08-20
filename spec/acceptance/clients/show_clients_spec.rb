require "rails_helper"

describe "showing a client", type: :feature do
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when a site has a client" do
      let!(:site) { create :site }
      let!(:client) { create :client, site: site }

      it "allows viewing clients" do
        visit "/sites/#{site.id}"

        expect(page).to have_content "List of Authorised Clients"
        expect(page).to have_content client.ip_range
        expect(page).to have_content client.shared_secret
      end
    end

    context "when a site has no clients" do
      let!(:site) { create :site }

      it "allows viewing clients" do
        visit "/sites/#{site.id}"

        expect(page).to_not have_content "List of Authorised Clients"
      end
    end
  end
end
