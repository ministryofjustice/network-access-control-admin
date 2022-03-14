require "rails_helper"

describe MacAuthenticationBypass, type: :model do
  subject { build :mac_authentication_bypass }

  it "has a valid bypass" do
    expect(subject).to be_valid
  end

  it { is_expected.to belong_to(:site) }
  it { is_expected.to validate_presence_of :address }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :description }
  it { is_expected.to validate_uniqueness_of(:address).case_insensitive }

  it "validates the format of the MAC addresses" do
    valid_mac_addresses = %i[
      aa-bb-cc-dd-ee-ff
      11-22-33-44-55-66
    ]

    invalid_mac_addresses = %i[
      ab:cd:de:fg:hi:jk
      AA-BB-CC-DD-EE-FF
      AABBCCDDEEFF
    ]

    valid_mac_addresses.each do |mac_address|
      result = build(:mac_authentication_bypass, address: mac_address)
      expect(result).to be_valid
    end

    invalid_mac_addresses.each do |mac_address|
      result = build(:mac_authentication_bypass, address: mac_address)
      expect(result).to be_invalid
    end
  end
end
