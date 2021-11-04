require "rails_helper"

describe "update rules", type: :feature do
  let(:policy) { create(:policy) }
  let(:rule) { create(:rule, policy: policy) }
  let(:custom_rule) { create(:rule, request_attribute: "3Com-User-Access-Level", value: "3Com-Administrator", policy: policy) }

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

      expect(page).to have_select("request-attribute", text: rule.request_attribute)
      expect(page).to have_select("Operator", text: rule.operator)
      expect(page).to have_field("Value", with: rule.value)

      select "Reply-Message", from: "request-attribute"
      select "contains", from: "Operator"
      fill_in "Value", with: "Hi hi"

      click_on "Update"

      expect(current_path).to eq("/policies/#{policy.id}")

      expect(page).to have_content("Successfully updated rule.")
      expect(page).to have_content "Reply-Message"
      expect(page).to have_content "contains"
      expect(page).to have_content "Hi hi"

      expect_audit_log_entry_for(editor.email, "update", "Rule")
    end

    it "does update an existing custom rule" do
      visit "policies/#{policy.id}"

      all(:link, "Edit")[1].click

      expect(page).to have_field("custom-request-attribute", with: custom_rule.request_attribute)
      expect(page).to have_select("Operator", text: custom_rule.operator)
      expect(page).to have_field("Value", with: custom_rule.value)

      fill_in "custom-request-attribute", with: "Aruba-AirGroup-Version"
      select "contains", from: "Operator"
      fill_in "Value", with: "AirGroup-v1"

      click_on "Update"

      expect(current_path).to eq("/policies/#{policy.id}")

      expect(page).to have_content("Successfully updated rule.")
      expect(page).to have_content "Aruba-AirGroup-Version"
      expect(page).to have_content "contains"
      expect(page).to have_content "AirGroup-v1"
    end
  end
end
