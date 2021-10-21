require "rails_helper"

describe "delete responses", type: :feature do
  it_behaves_like "response deletion", :policy, :policy_response
end
