# frozen_string_literal: true

class Rule < ApplicationRecord
  belongs_to :policy

  validates_presence_of :request_attribute, :operator, :value
  validates_inclusion_of :operator, in: %w[equals contains]

  audited
end
