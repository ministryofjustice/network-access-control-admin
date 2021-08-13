class Site < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :validate_number_of_fallback_policies

  has_many :clients, dependent: :destroy
  has_and_belongs_to_many :policies, -> { distinct }

private

  def validate_number_of_fallback_policies
    errors.add(:policies, "can only have one fallback policy") if policies.select(&:fallback).count > 1
  end

  audited
end
