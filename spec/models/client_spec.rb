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

  it "has a valid IP range" do
    valid_ip_addresses = %i[
      10.0.0.1/32
      10.0.0.2/24
      2001:0db8:85a3:0000:0000:8a2e:0370:7334/32
    ]

    invalid_ip_addresses = %i[
      300.0.0.1/32
      300.0.0.2/100
      invalid
    ]

    valid_ip_addresses.each do |ip|
      result = build(:client, ip_range: ip)
      expect(result).to be_valid
    end

    invalid_ip_addresses.each do |ip|
      result = build(:client, ip_range: ip)
      expect(result).to be_invalid
    end
  end
end
