require "rails_helper"

describe "update responses", type: :feature do
  it_behaves_like "response update", :mac_authentication_bypass, :mab_response
end
