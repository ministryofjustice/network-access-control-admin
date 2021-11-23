require "rails_helper"

describe "listing sites", type: :feature do
  context "when the user is unauthenticated" do
    it "does not allow viewing sites" do
      visit "/sites"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when sites exists" do
      let!(:site) { create :site, name: "Your brilliant site" }

      it "allows viewing sites" do
        visit "/sites"

        expect(page).to have_content site.name
        expect(page).to have_content date_format(site.created_at)
        expect(page).to have_content date_format(site.updated_at)
      end
    end

    context "searching and ordering" do
      let!(:first_site) { create(:site, name: "AA Site") }
      let!(:second_site) { create(:site, name: "BB Site") }
      let!(:third_site) { create(:site, name: "Site AAA") }

      before do
        visit "/sites"
      end

      it "searches by name" do
        expect(page).to have_content first_site.name
        expect(page).to have_content second_site.name

        fill_in "q_name_cont", with: "AA"
        click_on "Search"

        expect(page).to_not have_content second_site.name
        expect(page).to have_content first_site.name
        expect(page).to have_content third_site.name
      end

      it "orders by name" do
        click_on "Name"
        expect(page.text).to match(/AA Site.*BB Site/)

        click_on "Name"
        expect(page.text).to match(/BB Site.*AA Site/)
      end

      it "orders by updated_at" do
        second_site.update_attribute(:updated_at, 10.minutes.ago)
        first_site.update_attribute(:updated_at, 2.minutes.ago)

        click_on "Updated at"
        expect(page.text).to match(/#{date_format(second_site.updated_at)}.*#{date_format(first_site.updated_at)}/)

        click_on "Updated at"
        expect(page.text).to match(/#{date_format(first_site.updated_at)}.*#{date_format(second_site.updated_at)}/)
      end
    end

    context "pagination" do
      it "paginates" do
        52.times do |t|
          create(:site, name: "Site #{t}")
        end

        visit "/sites"

        expect(page.text).to_not include("Site 51")

        click_on "2"

        expect(page.text).to include("Site 51")
      end
    end
  end
end
