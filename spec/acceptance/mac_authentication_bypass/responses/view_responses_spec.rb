require "rails_helper"

describe "showing a response", type: :feature do
  it_behaves_like "response view", :mac_authentication_bypass, :mab_response
end
