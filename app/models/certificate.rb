class Certificate < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates_presence_of :description
  validate :fields_from_certificate_file, on: :create
  validates_inclusion_of :category, in: %w[EAP RADSEC]
  validates_uniqueness_of :filename

private

  def fields_from_certificate_file
    unless expiry_date.present? && subject.present?
      errors.add :certificate, "is missing or invalid"
    end
  end

  audited
end
