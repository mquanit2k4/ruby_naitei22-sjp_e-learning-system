class Test < ApplicationRecord
  has_many :questions, dependent: :destroy

  has_many :components, dependent: :destroy
end
