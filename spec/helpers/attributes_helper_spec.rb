require "rails_helper"

describe AttributesHelper do
  it "invalidates attributes with a partial match" do
    expect(described_class.valid_radius_attribute?("Attribute")).to be false
  end

  it "validates attributes with an exact match" do
    expect(described_class.valid_radius_attribute?("Custom-Attribute")).to be true
  end
end
