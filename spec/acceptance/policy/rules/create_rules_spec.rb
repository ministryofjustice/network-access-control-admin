require "rails_helper"

describe "create rules", type: :feature do
  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    context "when there is an existing policy" do
      let!(:policy) { create(:policy) }

      it "creates a new rule from dictionary dropdown" do
        visit "/policies/#{policy.id}"

        click_on "Add rule"

        expect(page.current_path).to eq(new_policy_rule_path(policy_id: policy))

        select "User-Name", from: "request-attribute"
        select "equals", from: "Operator"
        fill_in "Value", with: "VLAN"

        click_on "Create"

        expect(page).to have_content("Successfully created rule.")
        expect(page.current_path).to eq(policy_path(id: policy.id))
        expect_audit_log_entry_for(editor.email, "create", "Rule")
      end

      it "creates a new custom rule" do
        visit "/policies/#{policy.id}"

        click_on "Add rule"

        expect(page.current_path).to eq(new_policy_rule_path(policy_id: policy))

        choose "Custom"
        fill_in "custom-request-attribute", with: "Aruba-AirGroup-Device-Type"
        select "equals", from: "Operator"
        fill_in "Value", with: "Personal-Device"

        click_on "Create"

        expect(page).to have_content("Successfully created rule.")
      end

      it "displays error if form cannot be submitted" do
        visit new_policy_rule_path(policy_id: policy)

        click_on "Create"

        expect(page).to have_content "There is a problem"
      end
    end

    context "when there is an existing fallback policy" do
      let!(:policy) { create(:policy, fallback: true) }

      it "does not allow creating rules" do
        visit "/policies/#{policy.id}"

        expect(page).to_not have_content "Add rule"

        visit "/policies/#{policy.id}/rules/new"

        expect(page.current_path).to eq(policies_path)
      end
    end
  end
end
