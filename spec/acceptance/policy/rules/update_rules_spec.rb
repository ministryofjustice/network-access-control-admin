require "rails_helper"

describe "update rules", type: :feature do
  let(:policy) { create(:policy) }
  let(:rule) { create(:rule, policy:) }
  let(:custom_rule) { create(:rule, request_attribute: "3Com-User-Access-Level", value: "3Com-Administrator", policy:) }

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
      custom_rule
    end

    it "does update an existing rule" do
      visit "policies/#{policy.id}"

      first(:link, "Edit").click

      expect(page).to have_content(policy.name)

      expect(page).to have_select("rule_request_attribute", text: rule.request_attribute)
      expect(page).to have_select("Operator", text: rule.operator)
      expect(page).to have_field("Value", with: rule.value)

      select "User-Name", from: "rule_request_attribute"
      select "contains", from: "Operator"
      fill_in "Value", with: "Bob"

      click_on "Update"

      expect(current_path).to eq("/policies/#{policy.id}")

      expect(page).to have_content("Successfully updated rule.")
      expect(page).to have_content "User-Name"
      expect(page).to have_content "contains"
      expect(page).to have_content "Bob"

      expect_audit_log_entry_for(editor.email, "update", "Rule")
    end
  end
end
