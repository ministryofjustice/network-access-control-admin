class Policy < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates_presence_of :description
  validates_inclusion_of :fallback, in: [true, false]

  has_many :rules, dependent: :destroy
  has_many :responses, dependent: :destroy
  has_and_belongs_to_many :sites

  audited
end
