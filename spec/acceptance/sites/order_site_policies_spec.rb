require "rails_helper"

describe "order site policies", type: :feature do
  let(:site) { create(:site) }
  let(:least_important_policy) { create(:policy, name: "Least Important Policy") }
  let(:most_important_policy) { create(:policy, name: "Most Important Policy") }

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing site policies" do
      visit "/sites/#{site.to_param}/policies/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }
    let!(:least_important_site_policy) { create(:site_policy, site_id: site.id, policy_id: least_important_policy.id) }
    let!(:most_important_site_policy) { create(:site_policy, site_id: site.id, policy_id: most_important_policy.id) }

    before do
      login_as editor
    end

    it "updates the priority of site policies" do
      visit "/sites/#{site.id}"

      within "tr.govuk-table__row:nth-child(1)" do
        expect(page).to have_content("Least Important Policy")
        expect(page).to have_content(date_format(least_important_site_policy.created_at))
        expect(page).to have_content(date_format(least_important_site_policy.updated_at))
      end

      within "tr.govuk-table__row:nth-child(2)" do
        expect(page).to have_content("Most Important Policy")
        expect(page).to have_content(date_format(most_important_site_policy.created_at))
        expect(page).to have_content(date_format(most_important_site_policy.updated_at))
      end

      click_on "Change priorities"

      expect(current_path).to eq("/sites/#{site.to_param}/policies/edit")

      fill_in "Most Important Policy", with: "0"
      fill_in "Least Important Policy", with: "100"

      click_on "Update"

      expect(page).to have_content("Successfully updated the order of site policies.")

      within "tr.govuk-table__row:nth-child(1)" do
        expect(page).to have_content("Most Important Policy")
      end

      within "tr.govuk-table__row:nth-child(2)" do
        expect(page).to have_content("Least Important Policy")
      end
    end

    it "does not allow same order priority" do
      visit "/sites/#{site.id}"

      click_on "Change priorities"

      fill_in "Most Important Policy", with: "10"
      fill_in "Least Important Policy", with: "10"

      click_on "Update"

      expect(page).to have_content("Duplicate values entered for order priority.")
    end

    context "when there is a fallback policy" do
      let(:fallback_policy) { create(:policy, name: "Fallback Policy", fallback: true) }

      it "does no allow ordering fallback policies" do
        create(:site_policy, site_id: site.id, policy_id: fallback_policy.id)

        visit "/sites/#{site.id}"

        click_on "Change priorities"

        expect(page).not_to have_content("Fallback Policy")

        fill_in "Least Important Policy", with: "50"

        click_on "Update"

        expect(page).to have_content("Successfully updated the order of site policies.")
      end
    end
  end
end
