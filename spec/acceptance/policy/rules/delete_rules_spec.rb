require "rails_helper"

describe "delete rules", type: :feature do
  context "when the user is a viewer" do
    let(:editor) { create(:user, :editor) }
    let!(:policy) { create(:policy) }

    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting rules" do
      visit "/policies/#{policy.id}"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    context "when there is an existing policy with a rule" do
      let!(:policy) { create(:policy) }
      let!(:rule) { create(:rule, policy:) }

      it "delete an existing rule" do
        visit "/policies/#{policy.id}"

        find_link("Delete", href: "/policies/#{policy.id}/rules/#{rule.id}").click

        expect(page).to have_content("Are you sure you want to delete this rule?")
        expect(page).to have_content(rule.request_attribute)
        expect(page).to have_content(rule.operator)
        expect(page).to have_content(rule.value)
        expect(page).to have_content("Policy: #{policy.name}")

        click_on "Delete rule"

        expect(current_path).to eq("/policies/#{policy.id}")
        expect(page).to have_content("Successfully deleted rule.")
        expect(page).not_to have_content(rule.request_attribute)
        expect(page).not_to have_content(rule.operator)
        expect(page).not_to have_content(rule.value)

        expect_audit_log_entry_for(editor.email, "destroy", "Rule")
      end
    end
  end
end
