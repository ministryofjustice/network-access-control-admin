require "rails_helper"

describe "showing a policy", type: :feature do
  before do
    login_as create(:user, :reader)
  end

  context "when policies exist" do
    let!(:policy) { create :policy }

    it "allows viewing policies" do
      visit "/policies"

      expect(page).to have_content policy.name
      expect(page).to have_content policy.description
      expect(page).to have_content date_format(policy.created_at)
      expect(page).to have_content date_format(policy.updated_at)
    end
  end
end
