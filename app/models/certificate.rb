class Certificate < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates_presence_of :description
  validate :fields_from_certificate_file

private

  def fields_from_certificate_file
    unless expiry_date.present? && subject.present?
      errors.add :certificate, "Certificate is missing or invalid"
    end
  end

  audited
end
