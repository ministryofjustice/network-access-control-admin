FactoryBot.define do
  factory :user do
    email { "test@example.com" }

    trait :editor do
      editor { true }
    end

    trait :reader do
      editor { false }
    end
  end
end
