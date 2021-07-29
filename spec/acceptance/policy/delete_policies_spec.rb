require "rails_helper"

describe "delete policies", type: :feature do
  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting policies" do
      visit "/policies"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let!(:policy) { create(:policy) }
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "delete a policy" do
      visit "/policies"

      click_on "Delete"

      expect(page).to have_content("Are you sure you want to delete this policy?")
      expect(page).to have_content(policy.name)

      click_on "Delete policy"

      expect(current_path).to eq("/policies")
      expect(page).to have_content("Successfully deleted policy.")
      expect(page).not_to have_content(policy.name)

      expect_audit_log_entry_for(editor.email, "destroy", "Policy")
    end

    context "When a policy has rules" do
      before do
        create(:rule, policy: policy)
      end

      it "can delete the policy and the rules" do
        visit "/policies"

        click_on "Delete"
        click_on "Delete policy"

        expect(page).to have_content("Successfully deleted policy.")
        expect(page).not_to have_content(policy.name)

        expect_audit_log_entry_for(editor.email, "destroy", "Policy")
      end
    end
  end
end
