require "rails_helper"

describe "listing clients", type: :feature do
  before do
    login_as create(:user, :reader)
  end

  context "when a site has clients" do
    let!(:client) { create :client }

    it "allows viewing clients" do
      visit "/sites/#{client.site.id}"

      expect(page).to have_content client.ip_range
      expect(page).to have_content date_format(client.created_at)
      expect(page).to have_content date_format(client.updated_at)
    end
  end
end
