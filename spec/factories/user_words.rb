FactoryBot.define do
  factory :user_word do
    association :user
    association :word
    learned { false }

    trait :learned do
      learned { true }
    end
  end
end
