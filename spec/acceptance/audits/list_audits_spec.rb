require "rails_helper"

describe "showing audits", type: :feature do
  before do
    login_as create(:user, :reader)
  end

  context "when audits exist" do
    let!(:audit) { create :audit }

    context "when ordering" do
      let!(:first_audit) { create(:audit, action: "create", auditable_type: "Response") }
      let!(:second_audit) { create(:audit, action: "update", auditable_type: "Site") }
      let!(:third_audit) { create(:audit, action: "destroy", auditable_type: "MacAuthenticationBypass") }

      before do
        visit "/audits"
      end

      it "orders by Action" do
        click_on "Action"
        expect(page.text).to match(/create Policy.*destroy Mac authentication bypass.*update Site/)

        click_on "Action"
        expect(page.text).to match(/update Site.*destroy Mac authentication bypass.*create Policy/)
      end

      it "orders by record" do
        click_on "Record"
        expect(page.text).to match(/Mac authentication bypass.*Policy.*Response/)

        click_on "Record"
        expect(page.text).to match(/Response.*Policy.*Mac authentication bypass/)
      end

      it "orders by created at" do
        first_audit.update(created_at: Date.today - 1)
        second_audit.update(created_at: Date.today - 2)
        third_audit.update(created_at: Date.today)

        click_on "Created at"
        expect(page.text).to match(/#{date_format(second_audit.created_at)}.*#{date_format(first_audit.created_at)}.*#{date_format(third_audit.created_at)}/)

        click_on "Created at"
        expect(page.text).to match(/#{date_format(third_audit.created_at)}.*#{date_format(first_audit.created_at)}.*#{date_format(second_audit.created_at)}/)
      end
    end
  end
end
