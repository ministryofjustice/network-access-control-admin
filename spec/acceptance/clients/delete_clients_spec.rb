require "rails_helper"

describe "delete clients", type: :feature do
  context "when the user is a viewer" do
    let(:editor) { create(:user, :editor) }
    let!(:site) do
      Audited.audit_class.as_user(editor) do
        create(:site)
      end
    end

    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting clients" do
      visit "/sites/#{site.id}"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    context "when there is an existing site with a client" do
      let!(:site) { create(:site) }
      let!(:client) { create(:client, site: site) }

      it "deletes an existing client" do
        visit "/sites/#{site.id}"

        click_on "Delete"

        expect(page).to have_content("Are you sure you want to delete this client?")
        expect(page).to have_content(client.ip_range)
        expect(page).to have_content(client.tag)

        click_on "Delete client"

        expect(current_path).to eq("/sites/#{site.id}")
        expect(page).to have_content("Successfully deleted client.")
        expect(page).not_to have_content(client.ip_range)
        expect(page).not_to have_content(client.tag)
        expect(page).not_to have_content(client.shared_secret)

        expect_audit_log_entry_for(editor.email, "destroy", "Client")
      end
    end
  end
end
