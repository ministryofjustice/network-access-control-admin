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

  it "validates an updated response attribute" do
    editable_response = create(:policy_response)

    expect(editable_response).to be_valid

    editable_response.update(response_attribute: "Invalid-Attribute")

    expect(editable_response).to be_invalid
  end
end
