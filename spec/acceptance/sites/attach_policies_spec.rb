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

        expect(page).to_not have_content "Attach policies"
      end
    end
  end

  context "when the user is an editor" do
    before do
      login_as create(:user, :editor)
    end

    context "when both site and policies exists" do
      let!(:site) { create :site }
      let!(:first_policy) { create :policy, name: "First Policy" }
      let!(:second_policy) { create :policy, name: "Second Policy" }
      let!(:third_policy) { create :policy, name: "Third Policy" }

      it "does allow attaching policies to a site" do
        visit "/sites"

        click_on "Manage", match: :first

        click_on "Attach policies"

        expect(current_path).to eq("/sites/#{site.id}/policies")

        check "First Policy", allow_label_click: true
        check "Second Policy", allow_label_click: true

        click_on "Attach"

        expect(current_path).to eq("/sites/#{site.id}")

        expect(page).to have_content("Successfully attached policies to the site.")
        expect(page).to have_content("List of attached policies")
        expect(page).to have_content("First Policy")
        expect(page).to have_content("Second Policy")
        expect(page).to_not have_content("Third Policy")
      end

      context "when all policies are detached from a site" do
        it "does not show any attached policies" do
          visit "/sites/#{site.id}"

          click_on "Attach policies"

          check "First Policy", allow_label_click: true

          click_on "Attach"

          expect(page).to have_content("Successfully attached policies to the site.")

          click_on "Attach policies"

          uncheck "First Policy"

          click_on "Attach"

          expect(page).to_not have_content("List of attached policies")
          expect(page).to_not have_content("First Policy")
        end
      end

      context "when policies are already attached to a site" do
        it "does show the policy checked" do
          visit "/sites/#{site.id}"

          click_on "Attach policies"

          check "First Policy", allow_label_click: true

          click_on "Attach"

          expect(page).to have_content("Successfully attached policies to the site.")

          click_on "Attach policies"

          expect(page).to have_checked_field "First Policy"
        end
      end
    end
  end
end
