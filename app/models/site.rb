# frozen_string_literal: true

class Site < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  audited
end
