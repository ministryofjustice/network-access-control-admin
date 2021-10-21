RSpec.shared_examples "response update" do |domain, response|
  let(:created_domain) { create(domain) }
  let(:created_response) { create(response, { domain => created_domain }) }
  let(:custom_response) { create(response, { :response_attribute => "Custom-Attribute", domain => created_domain }) }

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
    end

    it "does update an existing response" do
      visit "/#{domain.to_s.pluralize}/#{created_domain.id}"

      first(:link, "Edit").click

      expect(page).to have_select("response-attribute", text: created_response.response_attribute)
      expect(page).to have_field("Value", with: created_response.value)

      select "Tunnel-Type", from: "response-attribute"
      fill_in "Value", with: "8765"

      click_on "Update"

      expect(current_path).to eq("/#{domain.to_s.pluralize}/#{created_domain.id}")

      expect(page).to have_content("Successfully updated response.")
      expect(page).to have_content "Tunnel-Type"
      expect(page).to have_content "8765"

      expect_audit_log_entry_for(editor.email, "update", "Response")
    end

    it "does update an existing custom response" do
      visit "/#{domain.to_s.pluralize}/#{created_domain.id}"

      all(:link, "Edit")[1].click

      expect(page).to have_field("custom-response-attribute", with: custom_response.response_attribute)
      expect(page).to have_field("Value", with: custom_response.value)

      fill_in "custom-response-attribute", with: "Updated-Custom-Attribute"
      fill_in "Value", with: "LAN"

      click_on "Update"

      expect(current_path).to eq("/#{domain.to_s.pluralize}/#{created_domain.id}")

      expect(page).to have_content("Successfully updated response.")
      expect(page).to have_content "Updated-Custom-Attribute"
      expect(page).to have_content "LAN"
    end
  end
end
