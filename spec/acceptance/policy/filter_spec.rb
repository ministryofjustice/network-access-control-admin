require "rails_helper"

describe "filtering a policy", type: :feature do
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when multiple policies exists" do
      let!(:site) { create :site, name: "First site" }
      let!(:second_site) { create :site, name: "Second site" }
      let!(:first_policy) { create :policy, name: "Police", description: "The civil force of a state", sites: [site] }
      let!(:second_policy) { create :policy, name: "Polymorphism", description: "The condition of occurring in several different forms", sites: [site] }
      let!(:third_policy) { create :policy, name: "Polyglot", description: "Knowing or using several languages", sites: [second_site] }

      it "allows filtering by site" do
        visit "/policies"

        select site.name, from: "filter"

        click_on "Search"

        expect(page).to have_select("filter", selected: site.name)

        expect(page).to have_content first_policy.name
        expect(page).to have_content first_policy.description
        expect(page).to have_content second_policy.name
        expect(page).to have_content second_policy.description

        expect(page).to_not have_content third_policy.name
        expect(page).to_not have_content third_policy.description
      end

      it "allows showing policies for all sites" do
        visit "/policies"

        select "All Sites", from: "filter"

        click_on "Search"

        expect(page).to have_select("filter", selected: [])

        expect(page).to have_content first_policy.name
        expect(page).to have_content first_policy.description
        expect(page).to have_content second_policy.name
        expect(page).to have_content second_policy.description
        expect(page).to have_content third_policy.name
        expect(page).to have_content third_policy.description
      end

      it "allows filtering by policy type" do
        visit "/policies"

        select "Fallback", from: "q_fallback"

        click_on "Search"

        expect(page).to have_select("q_fallback", selected: "Fallback")

        expect(page).to have_content site.policies.first.name
        expect(page).to have_content site.policies.first.description
        expect(page).to have_content second_site.policies.first.name
        expect(page).to have_content second_site.policies.first.description

        expect(page).to_not have_content first_policy.name
        expect(page).to_not have_content first_policy.description
        expect(page).to_not have_content second_policy.name
        expect(page).to_not have_content second_policy.description
        expect(page).to_not have_content third_policy.name
        expect(page).to_not have_content third_policy.description

        select "Non Fallback", from: "q_fallback"

        click_on "Search"

        expect(page).to have_select("q_fallback", selected: "Non Fallback")

        expect(page).to have_content first_policy.name
        expect(page).to have_content first_policy.description
        expect(page).to have_content second_policy.name
        expect(page).to have_content second_policy.description
        expect(page).to have_content third_policy.name
        expect(page).to have_content third_policy.description

        expect(page).to_not have_content site.policies.first.name
        expect(page).to_not have_content site.policies.first.description
        expect(page).to_not have_content second_site.policies.first.name
        expect(page).to_not have_content second_site.policies.first.description

        select "All Policies", from: "q_fallback"

        click_on "Search"

        expect(page).to have_select("q_fallback", selected: "All Policies")

        expect(page).to have_content first_policy.name
        expect(page).to have_content first_policy.description
        expect(page).to have_content second_policy.name
        expect(page).to have_content second_policy.description
        expect(page).to have_content third_policy.name
        expect(page).to have_content third_policy.description
        expect(page).to have_content site.policies.first.name
        expect(page).to have_content site.policies.first.description
        expect(page).to have_content second_site.policies.first.name
        expect(page).to have_content second_site.policies.first.description
      end
    end
  end
end
