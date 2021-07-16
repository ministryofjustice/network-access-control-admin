class Certificate < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates_presence_of :description, :expiry_date, :subject

  audited
end
