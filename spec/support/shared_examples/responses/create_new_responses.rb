RSpec.shared_examples "new response creation" do |domain, response, select_box_id|
  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    after do
      logout
    end

    context "when there is an existing response owner" do
      let!(:created_domain) { create(domain) }

      it "creates a new response from dictionary dropdown" do
        expect_service_deployment if domain == :mac_authentication_bypass

        visit "/#{domain.to_s.pluralize}/#{created_domain.id}"

        click_on "Add response"

        expect(page.current_path).to eq("/#{domain.to_s.pluralize}/#{created_domain.id}/#{response.to_s.pluralize}/new")

        expect(page).to have_content(created_domain.name)

        select "Tunnel-Type", from: select_box_id
        fill_in "Value", with: "VLAN"

        click_on "Create"

        expect(page).to have_content("Successfully created response.")
        expect(page.current_path).to eq("/#{domain.to_s.pluralize}/#{created_domain.id}")
        expect_audit_log_entry_for(editor.email, "create", "Response")
      end

      it "displays an error if form cannot be submitted" do
        visit "/#{domain.to_s.pluralize}/#{created_domain.id}/#{response.to_s.pluralize}/new"

        click_on "Create"

        expect(page).to have_content "There is a problem"
      end
    end
  end
end
