require "rails_helper"

describe Client, type: :model do
  subject { build :client }

  it "has a valid client" do
    expect(subject).to be_valid
  end

  it { is_expected.to belong_to :site }
  it { is_expected.to validate_presence_of :tag }
  it { is_expected.to validate_presence_of :shared_secret }
  it { is_expected.to validate_presence_of :ip_range }
end
