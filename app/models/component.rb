class Component < ApplicationRecord
  belongs_to :lesson
  belongs_to :test, optional: true
  belongs_to :word, optional: true

  has_many :user_words, dependent: :destroy
  has_many :test_results, dependent: :destroy

  enum type: {word: 0, test: 1, paragraph: 2}
end
