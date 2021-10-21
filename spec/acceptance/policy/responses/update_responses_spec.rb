require "rails_helper"

describe "update responses", type: :feature do
  it_behaves_like "response update", :policy, :policy_response
end
