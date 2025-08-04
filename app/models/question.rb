class Question < ApplicationRecord
  belongs_to :test
  has_many :answers, dependent: :destroy

  enum type: {single_choice: 0, multiple_choice: 1}
end
