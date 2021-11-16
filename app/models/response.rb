class Response < ApplicationRecord
  include ApplicationRecordHelper

  before_validation -> { trim_white_space(response_attribute, value) }

  validates_presence_of :response_attribute, :value
  validate -> { validate_radius_attribute(response_attribute, value) }, on: %i[create update]

  audited
end
