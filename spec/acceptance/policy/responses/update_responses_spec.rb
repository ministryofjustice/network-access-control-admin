require "rails_helper"

describe "update responses", type: :feature do
  let(:policy) { create(:policy) }
  let(:response) { create(:policy_response, policy: policy) }
  let(:custom_response) { create(:policy_response, response_attribute: "Custom-Attribute", policy: policy) }

  context "when the user is unauthenticated" do
    it "does not allow updating responses" do
      visit "/policies/#{policy.id}/policy_responses/#{response.id}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing responses" do
      visit "/policies/#{policy.id}"

      expect(page).not_to have_content "Edit"

      visit "/policies/#{policy.id}/policy_responses/#{response.id}/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      response
      custom_response
    end

    it "does update an existing response" do
      visit "policies/#{policy.id}"

      first(:link, "Edit").click

      expect(page).to have_select("response-attribute", text: response.response_attribute)
      expect(page).to have_field("Value", with: response.value)

      select "Tunnel-Type", from: "response-attribute"
      fill_in "Value", with: "5678"

      click_on "Update"

      expect(current_path).to eq("/policies/#{policy.id}")

      expect(page).to have_content("Successfully updated response.")
      expect(page).to have_content "Tunnel-Type"
      expect(page).to have_content "5678"

      expect_audit_log_entry_for(editor.email, "update", "Response")
    end

    it "does update an existing custom response" do
      visit "policies/#{policy.id}"

      all(:link, "Edit")[1].click

      expect(page).to have_field("custom-response-attribute", with: custom_response.response_attribute)
      expect(page).to have_field("Value", with: custom_response.value)

      fill_in "custom-response-attribute", with: "Updated-Custom-Attribute"
      fill_in "Value", with: "LAN"

      click_on "Update"

      expect(current_path).to eq("/policies/#{policy.id}")

      expect(page).to have_content("Successfully updated response.")
      expect(page).to have_content "Updated-Custom-Attribute"
      expect(page).to have_content "LAN"
    end
  end
end
