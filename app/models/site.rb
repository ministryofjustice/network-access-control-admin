class Site < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :clients, dependent: :destroy
  has_many :policies

  audited
end
