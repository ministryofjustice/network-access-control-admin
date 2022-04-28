require "rails_helper"

describe "update policies", type: :feature do
  let(:policy) { create(:policy) }

  context "when the user is unauthenticated" do
    it "does not allow updating policies" do
      visit "/policies/#{policy.to_param}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing policies" do
      visit "/policies"

      expect(page).not_to have_content "Change"

      visit "/policies/#{policy.to_param}/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      policy
    end

    it "does update an existing policy" do
      visit "/policies/#{policy.id}"

      first(:link, "Change").click

      expect(page).to have_field("Name", with: policy.name)

      fill_in "Name", with: "My London Policy"

      choose("policy_default_accept_false")

      click_on "Update"

      expect(current_path).to eq("/policies/#{policy.id}")

      expect(page).to have_content("My London Policy")
      expect(page).to have_content("Successfully updated policy.")

      first(:link, "Change").click

      expect(page).to have_checked_field("policy_default_accept_false")
      expect_audit_log_entry_for(editor.email, "update", "Policy")
    end
  end
end
