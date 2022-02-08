require "rails_helper"

describe "filtering audits", type: :feature do
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when multiple audits exists" do
      let!(:first_audit) { create(:audit, action: "create", auditable_type: "Response") }
      let!(:second_audit) { create(:audit, action: "update", auditable_type: "Site") }
      let!(:third_audit) { create(:audit, action: "destroy", auditable_type: "MacAuthenticationBypass") }

      before do
        visit "/audits"
      end

      it "finds an audit" do
        select "Site", from: "q_auditable_type"
        select "update", from: "q_action"

        click_on "Search"

        expect(page).to have_select("q_auditable_type", selected: "Site")
        expect(page).to have_select("q_action", selected: "update")

        within("#audit-results") do
          expect(page).to have_content second_audit.auditable_type
          expect(page).to_not have_content first_audit.auditable_type
          expect(page).to_not have_content third_audit.auditable_type
        end
      end

      it "does not find an audit" do
        select "Site", from: "q_auditable_type"
        select "create", from: "q_action"

        click_on "Search"

        within("#audit-results") do
          expect(page).to_not have_content second_audit.auditable_type
          expect(page).to_not have_content first_audit.auditable_type
          expect(page).to_not have_content third_audit.auditable_type
        end
      end
    end
  end
end
