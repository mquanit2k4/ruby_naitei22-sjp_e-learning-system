class Lesson < ApplicationRecord
  belongs_to :course
  belongs_to :creator, class_name: "User", foreign_key: "created_by"

  has_many :components, dependent: :destroy
  has_many :user_lessons, dependent: :destroy
end
