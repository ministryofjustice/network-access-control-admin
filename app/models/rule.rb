class Rule < ApplicationRecord
  belongs_to :policy
  belongs_to :request_attribute
  validates :operator, presence: true
  validates :value, presence: true
end
