require "rails_helper"

describe "delete policies", type: :feature do
  let!(:policy) { create(:policy) }

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting policies" do
      visit "/policies/#{policy.id}"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    it "delete a policy" do
      visit "/policies/#{policy.id}"

      find_link("Delete policy", href: "/policies/#{policy.id}").click

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
        visit "/policies/#{policy.id}"

        find_link("Delete", href: "/policies/#{policy.id}").click
        click_on "Delete policy"

        expect(page).to have_content("Successfully deleted policy.")
        expect(page).not_to have_content(policy.name)

        expect_audit_log_entry_for(editor.email, "destroy", "Policy")
      end
    end

    context "when a policy is attached to a site" do
      let!(:site) { create(:site, policies: [policy]) }
      let!(:another_site) { create(:site, policies: [policy]) }

      it "can delete the attached policy" do
        visit "/sites"

        find_link("Manage", href: "/sites/#{site.id}").click

        expect(page).to have_content(policy.name)

        visit "/policies/#{policy.id}"

        find_link("Delete", href: "/policies/#{policy.id}").click
        click_on "Delete policy"

        expect(page).to have_content("Successfully deleted policy.")
        expect(page).not_to have_content(policy.name)

        visit "/sites"

        find_link("Manage", href: "/sites/#{site.id}").click

        expect(page).not_to have_content(policy.name)
      end

      it "shows the number of associated sites when deleting the policy" do
        visit "/sites"

        find_link("Manage", href: "/sites/#{site.id}").click

        expect(page).to have_content(policy.name)

        visit "/policies/#{policy.id}"

        find_link("Delete", href: "/policies/#{policy.id}").click

        expect(page).to have_content("This policy is attached to 2 sites.")
      end
    end
  end
end
