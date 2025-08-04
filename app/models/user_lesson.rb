class UserLesson < ApplicationRecord
  belongs_to :user
  belongs_to :lesson

  enum status: {incomplete: 0, completed: 1}
end
