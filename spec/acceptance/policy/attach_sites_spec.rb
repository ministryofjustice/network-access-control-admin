require "rails_helper"

describe "attach sites to a policy", type: :feature do
  context "when the user is a reader" do
    before do
      login_as create(:user, :reader)
    end

    context "when both site and policy exists" do
      let!(:site) { create :site }
      let!(:policy) { create :policy }

      it "does not allow attaching policies to a site" do
        visit "/policies"

        click_on "View", match: :first

        expect(page).to_not have_content "Manage sites"
      end
    end
  end

  context "when the user is an editor" do
    before do
      login_as create(:user, :editor)
    end

    context "when both site and non-fallback policies exist" do
      let!(:site) { create :site, name: "First Site" }
      let!(:policy) { create :policy }

      it "does allow attaching sites to a policy" do
        visit "/policies"

        find_link("Manage", href: "/policies/#{policy.id}").click
        find_link("Manage sites", href: "/policies/#{policy.id}/sites?policy_id=#{policy.id}").click

        check "First Site", allow_label_click: true

        click_on "Update"

        expect(page).to have_content("Successfully attached policy to sites.")
      end
    end
  end
end
