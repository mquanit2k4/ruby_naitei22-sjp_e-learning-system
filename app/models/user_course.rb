class UserCourse < ApplicationRecord
  belongs_to :user
  belongs_to :course

  enum enrolment_status: {
    pending: 0,
    approved: 1,
    rejected: 2,
    in_progress: 3,
    completed: 4
  }
end
