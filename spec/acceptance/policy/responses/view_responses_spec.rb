require "rails_helper"

describe "showing a response", type: :feature do
  it_behaves_like "response view", :policy, :policy_response
end
