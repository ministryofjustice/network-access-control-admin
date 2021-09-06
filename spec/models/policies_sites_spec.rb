require "rails_helper"

RSpec.describe PoliciesSites, type: :model do
  subject { build :policies_sites }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "can have priority" do
    expect(subject.priority).to be_nil
    expect(subject.update(priority: 100)).to be_truthy
  end
end
