class Site < ApplicationRecord
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  audited
end
