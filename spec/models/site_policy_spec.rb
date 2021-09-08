require "rails_helper"

RSpec.describe SitePolicy, type: :model do
  subject { build :site_policy }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  it "can have priority" do
    expect(subject.priority).to be_nil
    expect(subject.update(priority: 100)).to be_truthy
  end
end
