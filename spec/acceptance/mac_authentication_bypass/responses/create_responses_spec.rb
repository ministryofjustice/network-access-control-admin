require "rails_helper"

describe "create responses", type: :feature do
  it_behaves_like "new response creation", :mac_authentication_bypass, :mab_response, "mab_response_response_attribute"
end
