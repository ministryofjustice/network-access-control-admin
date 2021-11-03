require "rails_helper"

describe "create responses", type: :feature do
  it "does deploy the service on successful creation" do
    editor = create(:user, :editor)
    bypass = create(:mac_authentication_bypass)

    login_as editor

    expect_service_deployment

    visit "/mac_authentication_bypasses/#{bypass.id}"

    click_on "Add response"

    select "Tunnel-Type", from: "response-attribute"

    fill_in "Value", with: "1234"

    click_on "Create"
  end

  it_behaves_like "new response creation", :mac_authentication_bypass, :mab_response
end
