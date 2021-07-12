# frozen_string_literal: true

FactoryBot.define do
  factory :vlan do
    sequence(:vlan) { |n| n }
    sequence(:common_name) { |n| "VLAN #{n}" }
    sequence(:remote_ip) { |n| "10.0.0.#{n}" }
  end
end
