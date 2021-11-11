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

  it "validates the request attribute" do
    valid_request_attributes = [
      { attribute: "User-Name", value: "Bob" },
      { attribute: "3Com-User-Access-Level", value: "3Com-Visitor" },
      { attribute: "Zyxel-Callback-Phone-Source", value: "User" },
    ]

    valid_request_attributes.each do |request_attribute|
      result = build(:rule, request_attribute: request_attribute.fetch(:attribute), value: request_attribute.fetch(:value))

      expect(result).to be_valid
    end

    result = build(:rule, request_attribute: "Invalid-Attribute")
    expect(result).to be_invalid
  end

  it "validates the request attribute with trailing whitespace" do
    result = build(:rule, request_attribute: " User-Name ", value: "Foo")

    result.valid?

    expect(result.request_attribute).to eq("User-Name")
  end

  it "validates an updated request attribute" do
    editable_rule = create(:rule)

    expect(editable_rule).to be_truthy

    editable_rule.update(request_attribute: "Invalid-Attribute")

    expect(editable_rule).to be_invalid
  end

  it "only allows specified values for operator" do
    subject.operator = "somethinginvalid"
    expect(subject).not_to be_valid
  end

  it "perists the amount of rules when a policy is saved" do
    policy = create(:policy)

    create(:rule, request_attribute: "User-Name", policy: policy)
    create(:rule, request_attribute: "User-Password", policy: policy)

    expect(Rule.first.policy.rule_count).to eq(2)
  end

  it "validates the uniquness of request attribute per policy when creating" do
    policy = create(:policy)

    rule = create(:rule, policy: policy, request_attribute: "User-Name", value: "Bob")

    expect(rule).to be_truthy

    duplicate_rule = build(:rule, policy: policy, request_attribute: "User-Name", value: "Bill")
    expect(duplicate_rule).to be_invalid
  end

  it "validates the uniqueness of the request attribute per policy when updating" do
    policy = create(:policy)

    first_rule = create(:rule, policy: policy, request_attribute: "User-Name", value: "Bob")
    create(:rule, policy: policy, request_attribute: "Class", value: "Something")

    expect(first_rule.update(request_attribute: "User-Name")).to be false
    expect(first_rule.errors.full_messages_for(:request_attribute)).to include("Request attribute has already been added")
  end
end
