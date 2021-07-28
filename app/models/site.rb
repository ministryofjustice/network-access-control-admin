class Site < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :clients, dependent: :destroy

  audited
end
