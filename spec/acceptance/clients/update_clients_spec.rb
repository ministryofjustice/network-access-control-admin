require "rails_helper"

describe "update clients", type: :feature do
  let(:site) { create(:site) }
  let(:client) { create(:client, site: site) }

  context "when the user is unauthenticated" do
    it "does not allow updating clients" do
      visit "/sites/#{site.id}/clients/#{client.id}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing clients" do
      visit "/sites/#{site.id}"

      expect(page).not_to have_content "Edit"

      visit "/sites/#{site.id}/clients/#{client.id}/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      client
    end

    it "does update an existing client" do
      visit "sites/#{site.id}"

      first(:link, "Edit").click

      expect(page).to have_field("IP / Subnet CIDR", with: client.ip_range)
      expect(page).to have_field("Tag", with: client.tag)
      expect(page).to have_field("Shared secret", with: client.shared_secret)

      fill_in "IP / Subnet CIDR", with: "132.654.132.456"
      fill_in "Tag", with: "Updated client"
      fill_in "Shared secret", with: "updated secret"

      click_on "Update"

      expect(current_path).to eq("/sites/#{site.id}")

      expect(page).to have_content("Successfully updated client.")
      expect(page).to have_content "132.654.132.456"
      expect(page).to have_content "Updated client"
      expect(page).to have_content "updated secret"

      expect_audit_log_entry_for(editor.email, "update", "Client")
    end
  end
end
