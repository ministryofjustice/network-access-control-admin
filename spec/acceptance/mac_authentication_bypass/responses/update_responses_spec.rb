require "rails_helper"

describe "update responses", type: :feature do
  it_behaves_like "response update", :mac_authentication_bypass, :mab_response, "mab_response_response_attribute"
end

describe "logged out response update attempt", type: :feature do
  let(:editor) { create(:user, :editor) }
  let!(:mab_response) { create(:mab_response) }

  before do
    login_as editor
  end

  it "redirects to the login page" do
    visit new_mac_authentication_bypass_mab_response_path(mac_authentication_bypass_id: mab_response.mac_authentication_bypass.id)

    select mab_response.response_attribute, from: "mab_response_response_attribute"
    fill_in "Value", with: mab_response.value

    click_on "Create"

    expect(page).to have_content("Response attribute has already been added")

    Timecop.travel(6.minutes.from_now)

    click_on "Create"

    expect(page.current_url).to eq(new_user_session_url)
  end
end
