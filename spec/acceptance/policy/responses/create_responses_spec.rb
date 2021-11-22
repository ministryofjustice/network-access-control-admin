require "rails_helper"

describe "create responses", type: :feature do
  it_behaves_like "new response creation", :policy, :policy_response, "policy_response_response_attribute"
end
