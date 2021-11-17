require "rails_helper"

describe "delete sites", type: :feature do
  let!(:site) { create(:site) }

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting sites" do
      visit "/sites/#{site.id}"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "delete a site" do
      visit "/sites/#{site.id}"

      find_link("Delete site", href: "/sites/#{site.id}").click

      expect(page).to have_content("Are you sure you want to delete this site?")
      expect(page).to have_content(site.name)
      expect(page).to have_content("#{site.clients.count} clients will be deleted.")
      expect(page).to have_content("#{site.policies.count} policy will be detached.")

      click_on "Delete site"

      expect(current_path).to eq("/sites")
      expect(page).to have_content("Successfully deleted site.")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).not_to have_content(site.name)

      expect_audit_log_entry_for(editor.email, "destroy", "Site")
    end
  end
end
