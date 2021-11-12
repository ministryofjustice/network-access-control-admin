RSpec.shared_examples "response deletion" do |domain, response|
  context "when the user is a viewer" do
    let!(:created_domain) { create(domain) }

    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting responses" do
      visit "/#{domain.to_s.pluralize}/#{created_domain.id}"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor

      expect_service_deployment if domain == :mac_authentication_bypass
    end

    context "when there is an existing domain with a response" do
      let!(:created_domain) { create(domain) }
      let!(:created_response) { create(response, { domain => created_domain }) }

      it "delete an existing response" do
        visit "/#{domain.to_s.pluralize}/#{created_domain.id}"

        click_on "Delete"

        expect(page).to have_content("Are you sure you want to delete this response?")
        expect(page).to have_content("Response attribute: #{created_response.response_attribute}")
        expect(page).to have_content("Value: #{created_response.value}")
        expect(page).to have_content(created_domain.name)

        click_on "Delete response"

        expect(current_path).to eq("/#{domain.to_s.pluralize}/#{created_domain.id}")
        expect(page).to have_content("Successfully deleted response.")
        expect(page).not_to have_content(created_response.response_attribute)
        expect(page).not_to have_content(created_response.value)

        expect_audit_log_entry_for(editor.email, "destroy", "Response")
      end
    end
  end
end
