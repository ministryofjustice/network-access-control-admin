class Response < ApplicationRecord
  validates_presence_of :response_attribute, :value

  audited
end
