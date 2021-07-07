class Policy < ApplicationRecord
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :description, presence: true

  audited
end
