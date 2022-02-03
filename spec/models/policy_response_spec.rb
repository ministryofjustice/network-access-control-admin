require "rails_helper"

describe PolicyResponse, type: :model do
  subject { build :policy_response }

  it "has a valid response" do
    expect(subject).to be_valid
  end

  it { is_expected.to belong_to :policy }
  it { is_expected.to validate_presence_of :response_attribute }
  it { is_expected.to validate_presence_of :value }

  it "validates the response attribute" do
    valid_response_attributes = [
      { attribute: "User-Name", value: "Bob" },
      { attribute: "3Com-User-Access-Level", value: "3Com-Visitor" },
      { attribute: "Zyxel-Callback-Phone-Source", value: "User" },
    ]

    valid_response_attributes.each do |response_attribute|
      result = build(:policy_response, response_attribute: response_attribute.fetch(:attribute), value: response_attribute.fetch(:value))

      expect(result).to be_valid
    end

    result = build(:policy_response, response_attribute: "Invalid-Attribute")

    expect(result).to be_invalid
  end

  it "validates the response attribute with trailing whitespace" do
    result = build(:policy_response, response_attribute: " User-Name ", value: "Foo")

    result.valid?

    expect(result.response_attribute).to eq("User-Name")
  end

  it "validates the value with leading and trailing whitespace" do
    result = build(:policy_response, response_attribute: "Tunnel-Type", value: " VLAN ")

    result.valid?

    expect(result.value).to eq("VLAN")
  end

  it "validates an updated response attribute" do
    editable_response = create(:policy_response)

    expect(editable_response).to be_truthy

    editable_response.update(response_attribute: "Invalid-Attribute")

    expect(editable_response).to be_invalid
  end

  it "validates the uniquness of response attribute per policy when creating" do
    policy = create(:policy)

    policy_response = create(:policy_response, policy:, response_attribute: "User-Name", value: "Bob")

    expect(policy_response).to be_truthy

    duplicate_policy_response = build(:policy_response, policy:, response_attribute: "User-Name", value: "Bill")
    expect(duplicate_policy_response).to be_invalid
  end

  it "validates the uniqueness of the response attribute per policy when updating" do
    policy = create(:policy)

    first_policy_response = create(:policy_response, policy:, response_attribute: "User-Name", value: "Bob")
    create(:policy_response, policy:, response_attribute: "Class", value: "Something")

    expect(first_policy_response.update(response_attribute: "Class")).to be false
    expect(first_policy_response.errors.full_messages_for(:response_attribute)).to include("Response attribute has already been added")

    expect(first_policy_response.update(response_attribute: "User-Name")).to be true
    expect(first_policy_response.update(value: "Something else")).to be true
  end
end
