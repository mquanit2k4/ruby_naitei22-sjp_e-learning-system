class Word < ApplicationRecord
  has_many :components, dependent: :destroy

  enum type: {
    noun: 0,
    pronoun: 1,
    verb: 2,
    adjective: 3,
    adverb: 4,
    preposition: 5,
    conjunction: 6,
    interjection: 7
  }
end
