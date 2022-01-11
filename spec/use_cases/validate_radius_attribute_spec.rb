require "rails_helper"

describe UseCases::ValidateRadiusAttribute do
  subject(:use_case) do
    described_class.new
  end

  let(:valid_attributes) do
    [
      { key: "Aruba-User-Vlan", value: 777 },
      { key: "Aruba-AP-Group", value: "Freeform text field" },
      { key: "Aruba-AirGroup-Device-Type", value: %w[Personal-Device Shared-Device Deleted-Device] },
      { key: "Aruba-AP-IP-Address", value: "10.0.0.1" },
      { key: "Alc-Ipv6-Secondary-Dns", value: "2001:0db8:85a3:0000:0000:8a2e:0370:7334" },
      { key: "Lucent-User-Acct-Expiration", value: 1_636_106_724 },
      { key: "Acct-Input-Octets-64", value: 123 },
    ]
  end

  let(:invalid_attributes) do
    [
      { key: "Invalid-Key", value: "whatever", expected_message: "Unknown attribute 'Invalid-Key'" },
      { key: "Aruba-User-Vlan", value: "not integer", expected_message: "Unknown or invalid value \"not integer\" for attribute Aruba-User-Vlan" },
      { key: "Aruba-AirGroup-Device-Type", value: %w[unsupported-item], expected_message: "Unknown or invalid value \"unsupported-item\" for attribute Aruba-AirGroup-Device-Type" },
      { key: "Aruba-AP-IP-Address", value: "not an ip", expected_message: "Failed resolving \"not an ip\" to IPv4 address: Name does not resolve" },
      { key: "Alc-Ipv6-Secondary-Dns", value: "not an ipv6 address", expected_message: "Failed resolving \"not an ipv6 address\" to IPv6 address: Name does not resolve" },
      { key: "Lucent-User-Acct-Expiration", value: "Not a unix timestamp", expected_message: "failed to parse time string \"Not a unix timestamp\"" },
      { key: "Acct-Input-Octets-64", value: "Not an integer64", expected_message: "Failed parsing \"Not an integer64\" as unsigned 64bit integer" },
      { key: "IPv6-6rd-Configuration", value: 93_293, expected_message: "Cannot parse TLV" },
    ]
  end

  let(:valid_rule_match_attributes) do
    [
      { key: "Tunnel-Type", value: "VLA", operator: "contains" },
      { key: "Tunnel-Medium-Type", value: "IEEE", operator: "contains" },
      { key: "Aruba-AirGroup-Device-Type", value: "Personal", operator: "contains" },
    ]
  end

  it "Returns success for valid attributes" do
    assert_attributes(valid_attributes, true)
  end

  it "Returns an error for invalid attributes" do
    assert_attributes(invalid_attributes, false)
  end

  it "Allows using 'contains' syntax with partial strings" do
    assert_attributes(valid_rule_match_attributes, true)
  end

private

  def assert_attributes(attributes, success)
    attributes.each do |attribute|
      value = attribute.fetch(:value)
      message = attribute.fetch(:expected_message, "")
      operator = attribute.fetch(:operator, "")

      if value.is_a?(Array)
        value.each do |list_value|
          result = subject.call(attribute: attribute.fetch(:key), value: list_value, operator: operator)
          expect(result).to eq({ success: success, message: message })
        end
      else
        result = subject.call(attribute: attribute.fetch(:key), value: value, operator: operator)
        expect(result).to eq({ success: success, message: message })
      end
    end
  end
end
