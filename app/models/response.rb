class Response < ApplicationRecord
  belongs_to :policy

  validates_presence_of :response_attribute, :value

  audited
end
