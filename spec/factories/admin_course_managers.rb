FactoryBot.define do
  factory :admin_course_manager do
    association :user, factory: [:user, :admin]
    association :course
  end
end
