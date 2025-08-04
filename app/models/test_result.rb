class TestResult < ApplicationRecord
  belongs_to :user
  belongs_to :component

  enum status: {passed: 0, failed: 1}
end
