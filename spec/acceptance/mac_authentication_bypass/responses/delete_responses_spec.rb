require "rails_helper"

describe "delete responses", type: :feature do
  it_behaves_like "response deletion", :mac_authentication_bypass, :mab_response
end
