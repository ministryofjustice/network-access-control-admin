require "rails_helper"

describe AttributesHelper do
  it "valid attribute" do
    expect(described_class.validate("Tunnel-Type", "VLAN")).to eq({ success: true })
  end

  it "invalid attribute key" do
    expect(described_class.validate("Tunnel-Typezzz", "VLAN")).to eq({ success: false, message: "Tunnel-Typezzz is not a valid attribute" })
  end

  it "invalid attribute value" do
    expect(described_class.validate("Tunnel-Type", "VLANzzzz")).to eq({ success: false, message: "VLANzzzz is not a valid value for Tunnel-Type" })
  end

  it "invalid attribute key and value" do
    expect(described_class.validate("Tunnel-Typezzzz", "VLANzzzz")).to eq({ success: false, message: "Tunnel-Typezzzz is not a valid attribute" })
  end
end
