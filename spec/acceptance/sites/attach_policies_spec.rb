require "rails_helper"

describe "attach policies to a site", type: :feature do
  context "when the user is a reader" do
    before do
      login_as create(:user, :reader)
    end

    context "when both site and policy exists" do
      let!(:site) { create :site }
      let!(:policy) { create :policy }

      it "does not allow attaching policies to a site" do
        visit "/sites"

        click_on "View", match: :first

        expect(page).to_not have_content "Manage policies"
      end
    end
  end

  context "when the user is an editor" do
    before do
      login_as create(:user, :editor)
    end

    context "when both site and non-fallback policies exists" do
      let!(:site) { create :site }
      let!(:first_policy) { create :policy, name: "First Policy" }
      let!(:second_policy) { create :policy, name: "Second Policy" }
      let!(:third_policy) { create :policy, name: "Third Policy" }

      it "does allow attaching policies to a site" do
        visit "/sites"

        find_link("Manage", href: "/sites/#{site.id}").click
        find_link("Manage policies", href: "/sites/#{site.id}/policies?site_id=#{site.id}").click

        check "First Policy", allow_label_click: true
        check "Second Policy", allow_label_click: true

        click_on "Update"

        expect(current_path).to eq("/sites/#{site.id}")

        expect(page).to have_content("Successfully updated site policies.")
        expect(page).to have_content("List of attached policies")
        expect(page).to have_content("First Policy")
        expect(page).to have_content("Second Policy")
        expect(page).to_not have_content("Third Policy")
      end

      it "does allow searching policies" do
        visit "/sites"

        find_link("Manage", href: "/sites/#{site.id}").click
        find_link("Manage policies", href: "/sites/#{site.id}/policies?site_id=#{site.id}").click

        fill_in "search", with: "Second Pol"

        click_on "Search"

        expect(page).to have_content(second_policy.name)
        expect(page).to_not have_content(first_policy.name)
        expect(page).to_not have_content(third_policy.name)

        check "Second Policy", allow_label_click: true

        click_on "Update"

        expect(current_path).to eq("/sites/#{site.id}")

        expect(page).to have_content("Successfully updated site policies.")
        expect(page).to have_content("List of attached policies")
        expect(page).to have_content("Second Policy")
      end

      context "when there is a policy attached to a site" do
        let!(:site) { create :site, policies: [first_policy] }

        it "does allow viewing the policy" do
          visit "/sites/#{site.id}"

          click_on "View", match: :first

          expect(current_path).to eq("/policies/#{first_policy.id}")

          expect(page).to have_content "First Policy"
        end

        it "does allow detaching the policy" do
          visit "/sites/#{site.id}"

          click_on "Manage policies"

          expect(page).to have_checked_field "First Policy"

          uncheck "First Policy"

          click_on "Update"

          expect(page).to_not have_content("First Policy")
        end

        it "keeps the fallback policy for the site when attaching new policies" do
          visit "/sites/#{site.id}"

          click_on "Manage policies"
          check "First Policy"
          click_on "Update"

          expect(page).to have_content("First Policy")
          expect(page).to have_content("Fallback policy: Fallback policy for #{site.name}")
        end
      end
    end

    context "when both site and fallback policies exist" do
      let!(:site) { create :site }
      let!(:first_policy) { create :policy, name: "First Policy" }
      let!(:first_fallback_policy) { create :policy, name: "FB", fallback: true }

      it "does not show fallback policy in policies checkbox list" do
        visit "/sites"

        click_on "Manage", match: :first

        click_on "Manage policies"

        expect(page).to_not have_css ".govuk-checkboxes__label", text: "FB"
      end
    end
  end
end
