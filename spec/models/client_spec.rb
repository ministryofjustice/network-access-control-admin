require "rails_helper"

describe Client, type: :model do
  subject { build :client }

  it "has a valid client" do
    expect(subject).to be_valid
  end

  it { is_expected.to belong_to :site }
  it { is_expected.to validate_presence_of :shared_secret }
  it { is_expected.to validate_presence_of :ip_range }
  it { is_expected.to validate_uniqueness_of(:ip_range).scoped_to(:radsec).case_insensitive }

  it "has a valid IP range" do
    valid_ip_addresses = %i[
      10.0.0.1
      10.0.0.2/24
    ]

    invalid_ip_addresses = %i[
      300.0.0.1/32
      300.0.0.2/100
      2001:0db8:85a3:0000:0000:8a2e:0370:7334
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

  it "appends a valid IP with /32" do
    client = build(:client, ip_range: "10.0.0.1")
    client.save
    expect(client.ip_range).to eq("10.0.0.1/32")
  end

  it "validates an updated IP range" do
    editable_client = create(:client)

    expect(editable_client).to be_truthy

    editable_client.update(ip_range: "Something-Invalid")

    expect(editable_client).to be_invalid
  end

  context "creating a client" do
    it "does not allow overlapping IPs" do
      ip1 = "127.0.0.1/32"
      ip2 = "127.0.0.1/16"

      create(:client, ip_range: ip1)
      expect(build(:client, ip_range: ip2)).to be_invalid
    end

    it "does allow overlapping IPs for a RadSec client" do
      ip1 = "127.0.0.1/32"
      ip2 = "127.0.0.1/16"

      create(:client, ip_range: ip1)
      expect(build(:client, ip_range: ip2, radsec: true)).to be_valid
    end

    it "does not allow overlapping IPs for multiple RadSec clients" do
      ip1 = "127.0.0.1/32"
      ip2 = "127.0.0.1/16"

      create(:client, ip_range: ip1, radsec: true)
      expect(build(:client, ip_range: ip2, radsec: true)).to be_invalid
    end
  end

  context "updating a client" do
    it "does allow updating the existing client ip" do
      client = create(:client)
      expect { client.save! }.to_not raise_error
    end
  end
end
