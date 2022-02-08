FactoryBot.define do
  factory :audit do
    user

    action { "create" }
    auditable_type { "Policy" }
  end
end
