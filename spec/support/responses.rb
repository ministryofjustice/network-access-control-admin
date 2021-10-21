RSpec.shared_examples "responses" do |domain|
  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    after do
      logout
    end

    context "when there is an existing MAC authentication bypass" do
      let!(:created_domain) { create(domain) }

      it "creates a new response from dictionary dropdown" do
        visit "/mac_authentication_bypasses/#{created_domain.id}"

        click_on "Add response"

        # expect(page.current_path).to eq(new_mac_authentication_bypass_mab_response_path(mac_authentication_bypass_id: domain))

        select "Tunnel-Type", from: "response-attribute"
        fill_in "Value", with: "1234"

        click_on "Create"

        expect(page).to have_content("Successfully created response.")
        # expect(page.current_path).to eq(mac_authentication_bypass_path(id: domain.id))
        expect_audit_log_entry_for(editor.email, "create", "Response")
      end

      it "creates a new custom response" do
        visit "/mac_authentication_bypasses/#{created_domain.id}"

        click_on "Add response"

        # expect(page.current_path).to eq(new_mac_authentication_bypass_mab_response_path(mac_authentication_bypass_id: domain))

        choose "Custom"
        fill_in "custom-response-attribute", with: "Custom-Tunnel-Type"
        fill_in "Value", with: "1234"

        click_on "Create"

        expect(page).to have_content("Successfully created response.")
        # expect(page.current_path).to eq(mac_authentication_bypass_path(id: mac_authentication_bypass.id))
        expect_audit_log_entry_for(editor.email, "create", "Response")
      end

      xit "displays an error if form cannot be submitted" do
        visit new_mac_authentication_bypass_mab_response_path(mac_authentication_bypass_id: mac_authentication_bypass)

        click_on "Create"

        expect(page).to have_content "There is a problem"
      end
    end
  end
end
