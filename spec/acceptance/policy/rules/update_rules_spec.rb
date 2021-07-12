# frozen_string_literal: true

require "rails_helper"

describe "update rules", type: :feature do
  let(:policy) do
    Audited.audit_class.as_user(User.first) do
      create(:policy)
    end
  end
  let(:rule) { create(:rule, policy: policy) }

  context "when the user is unauthenticated" do
    it "does not allow updating rules" do
      visit "/policies/#{policy.id}/rules/#{rule.id}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing rules" do
      visit "/policies/#{policy.id}"

      expect(page).not_to have_content "Edit"

      visit "/policies/#{policy.id}/rules/#{rule.id}/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      rule
    end

    it "does update an existing rule" do
      visit "policies/#{policy.id}"

      first(:link, "Edit").click

      expect(page).to have_field("Request attribute", with: rule.request_attribute)
      expect(page).to have_select("Operator", text: rule.operator)
      expect(page).to have_field("Value", with: rule.value)

      fill_in "Request attribute", with: "Tunnel-Type"
      select "contains", from: "Operator"
      fill_in "Value", with: "LAN"

      click_on "Update"

      expect(current_path).to eq("/policies/#{policy.id}")

      expect(page).to have_content("Successfully updated rule.")
      expect(page).to have_content "Tunnel-Type"
      expect(page).to have_content "contains"
      expect(page).to have_content "LAN"

      expect_audit_log_entry_for(editor.email, "update", "Rule")
    end
  end
end
