# frozen_string_literal: true

require "rails_helper"

describe Rule, type: :model do
  subject { build :rule }

  it "has a valid rule" do
    expect(subject).to be_valid
  end

  it { is_expected.to belong_to :policy }
  it { is_expected.to validate_presence_of :operator }
  it { is_expected.to validate_presence_of :value }
  it { is_expected.to validate_presence_of :request_attribute }

  it "only allows specified values for operator" do
    subject.operator = "somethinginvalid"
    expect(subject).not_to be_valid
  end
end
