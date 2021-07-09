require "rails_helper"

describe "delete rules", type: :feature do
  context "when the user is a viewer" do
    let(:editor) { create(:user, :editor) }
    let!(:policy) do
      Audited.audit_class.as_user(editor) do
        create(:policy)
      end
    end

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
      let!(:rule) { create(:rule, policy: policy) }

      it "delete an existing rule" do
        visit "/policies/#{policy.id}"

        click_on "Delete"

        expect(page).to have_content("Are you sure you want to delete this rule?")
        expect(page).to have_content(rule.request_attribute)
        expect(page).to have_content(rule.operator)
        expect(page).to have_content(rule.value)

        click_on "Delete rule"

        # expect(current_path).to eq("/policies/#{policy.id}")
        expect(page).to have_content("Successfully deleted rule.")
        expect(page).not_to have_content(rule.request_attribute)
        expect(page).not_to have_content(rule.operator)
        expect(page).not_to have_content(rule.value)

        expect_audit_log_entry_for(editor.email, "destroy", "Rule")
      end
    end
  end
end
