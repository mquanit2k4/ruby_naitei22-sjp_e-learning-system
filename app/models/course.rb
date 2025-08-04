class Course < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "created_by"

  has_many :lessons, dependent: :destroy

  has_many :user_courses, dependent: :destroy

  has_many :users, through: :user_courses

  has_many :admin_course_managers, dependent: :destroy

  has_many :admins, through: :admin_course_managers, source: :user

  has_one_attached :thumbnail
end
