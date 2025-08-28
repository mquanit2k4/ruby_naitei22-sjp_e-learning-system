FactoryBot.define do
  factory :user_lesson do
    association :user
    association :lesson
    status { :not_started }
    grade { 0 }

    trait :completed do
      status { :completed }
      grade { 85 }
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :passed do
      status { :completed }
      grade { 80 }
    end

    trait :failed do
      status { :completed }
      grade { 40 }
    end
  end
end
