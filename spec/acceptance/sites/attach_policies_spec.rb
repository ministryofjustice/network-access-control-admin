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

    context "when both site and non-fallback policies exists" do
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

        click_on "Update"

        expect(current_path).to eq("/sites/#{site.id}")

        expect(page).to have_content("Successfully updated site policies.")
        expect(page).to have_content("List of attached policies")
        expect(page).to have_content("First Policy")
        expect(page).to have_content("Second Policy")
        expect(page).to_not have_content("Third Policy")
      end

      context "when there is a policy attached to a site" do
        let!(:site) { create :site, policies: [first_policy] }

        it "does allow detaching the policy" do
          visit "/sites/#{site.id}"

          click_on "Attach policies"

          expect(page).to have_checked_field "First Policy"

          uncheck "First Policy"

          click_on "Update"

          expect(page).to_not have_content("List of attached policies")
          expect(page).to_not have_content("First Policy")
        end
      end
    end

    context "when both site and fallback policies exists" do
      let!(:site) { create :site }
      let!(:first_fallback_policy) { create :policy, name: "First FB Policy", fallback: true }
      let!(:second_fallback_policy) { create :policy, name: "Second FB Policy", fallback: true }

      it "does not allow attaching multiple fallback policies to a site" do
        visit "/sites"

        click_on "Manage", match: :first

        click_on "Attach policies"

        expect(current_path).to eq("/sites/#{site.id}/policies")

        check "First FB Policy", allow_label_click: true
        check "Second FB Policy", allow_label_click: true

        click_on "Update"

        expect(page).to have_content("There is a problem")
        expect(page).to have_content("Policies can only have one fallback policy")

        check "First FB Policy", allow_label_click: true

        click_on "Update"

        expect(page).to have_content("Successfully updated site policies.")
        expect(page).to have_content("List of attached policies")
        expect(page).to have_content("First FB Policy")
        expect(page).to_not have_content("Second FB Policy")
      end
    end
  end
end
