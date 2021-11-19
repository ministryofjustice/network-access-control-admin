require "rails_helper"

describe "searching a policy", type: :feature do
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when multiple policies exists" do
      let!(:first_policy) { create :policy, name: "Police", description: "The civil force of a state" }
      let!(:second_policy) { create :policy, name: "Polymorphism", description: "The condition of occurring in several different forms" }
      let!(:third_policy) { create :policy, name: "Polyglot", description: "Knowing or using several languages" }

      it "allows searching for name and description fields" do
        visit "/policies"

        expect(page).to have_content first_policy.name
        expect(page).to have_content first_policy.description
        expect(page).to have_content second_policy.name
        expect(page).to have_content second_policy.description
        expect(page).to have_content third_policy.name
        expect(page).to have_content third_policy.description

        fill_in "search", with: "Poly"

        click_on "Search"

        expect(page).to have_field("search", with: "Poly")

        expect(page).to have_content third_policy.name
        expect(page).to have_content third_policy.description
        expect(page).to have_content second_policy.name
        expect(page).to have_content second_policy.description

        expect(page).to_not have_content first_policy.name
        expect(page).to_not have_content first_policy.description

        fill_in "search", with: "The c"

        click_on "Search"

        expect(page).to have_field("search", with: "The c")

        expect(page).to have_content first_policy.name
        expect(page).to have_content first_policy.description
        expect(page).to have_content second_policy.name
        expect(page).to have_content second_policy.description

        expect(page).to_not have_content third_policy.name
        expect(page).to_not have_content third_policy.description
      end
    end
  end
end
