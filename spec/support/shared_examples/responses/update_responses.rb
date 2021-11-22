RSpec.shared_examples "response update" do |domain, response, select_box_id|
  let(:created_domain) { create(domain) }
  let(:created_response) { create(response, { domain => created_domain }) }
  let(:custom_response) { create(response, { :response_attribute => "3Com-User-Access-Level", :value => "3Com-Visitor", domain => created_domain }) }

  context "when the user is unauthenticated" do
    it "does not allow updating responses" do
      visit "/#{domain.to_s.pluralize}/#{created_domain.id}/#{response.to_s.pluralize}/#{created_response.id}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing responses" do
      visit "/#{domain.to_s.pluralize}/#{created_domain.id}"

      expect(page).not_to have_content "Edit"

      visit "/#{domain.to_s.pluralize}/#{created_domain.id}/#{response.to_s.pluralize}/#{created_response.id}/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      created_response
      custom_response

      expect_service_deployment if domain == :mac_authentication_bypass
    end

    it "does update an existing response" do
      visit "/#{domain.to_s.pluralize}/#{created_domain.id}"

      first(:link, "Edit").click

      expect(page).to have_content(created_domain.name)

      expect(page).to have_select(select_box_id, text: created_response.response_attribute)
      expect(page).to have_field("Value", with: created_response.value)

      select "Reply-Message", from: select_box_id
      fill_in "Value", with: "Hello to you"

      click_on "Update"

      expect(current_path).to eq("/#{domain.to_s.pluralize}/#{created_domain.id}")

      expect(page).to have_content("Successfully updated response.")
      expect(page).to have_content "Reply-Message"
      expect(page).to have_content "Hello to you"

      expect_audit_log_entry_for(editor.email, "update", "Response")
    end
  end
end
