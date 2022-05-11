class Certificate < ApplicationRecord
  paginates_per 50

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates_presence_of :description
  validate :fields_from_certificate_file, on: :create
  validates_inclusion_of :category, in: %w[EAP RADSEC]
  validates_uniqueness_of :filename, scope: :category
  validates_format_of :filename, with: /\A.+(.pem)+\z/
  validate :validate_server_certificate

  def server_certificate?
    filename == "server.pem"
  end

  def validate_server_certificate
    return unless server_certificate?

    results = UseCases::ValidateServerCertificate.new(certificate: contents).call

    results.each do |result|
      errors.add :base, result
    end
  end

private

  def fields_from_certificate_file
    unless expiry_date.present? && subject.present?
      errors.add :certificate, "is missing or invalid"
    end
  end

  audited
end
