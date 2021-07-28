require "rails_helper"

describe "create clients", type: :feature do
  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    context "when there is an existing site" do
      let!(:site) { create(:site) }

      it "creates a new client" do
        visit "/sites/#{site.id}"

        click_on "Add client"

        expect(page.current_path).to eq(new_site_client_path(site_id: site))

        fill_in "IP / Subnet CIDR", with: "123.123.123.123"
        fill_in "Tag", with: "Some client"
        fill_in "Shared secret", with: "secret secret"

        click_on "Create"

        expect(page).to have_content("Successfully created client.")
        expect(page.current_path).to eq(site_path(id: site.id))
        expect_audit_log_entry_for(editor.email, "create", "Client")
      end

      it "displays error if form cannot be submitted" do
        visit new_site_client_path(site_id: site)

        click_on "Create"

        expect(page).to have_content "There is a problem"
      end
    end
  end
end
