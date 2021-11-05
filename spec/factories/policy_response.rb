FactoryBot.define do
  factory :policy_response do
    policy

    response_attribute { "Tunnel-Type" }
    value { "VLAN" }
  end
end
