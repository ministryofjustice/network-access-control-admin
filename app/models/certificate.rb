class Certificate < ApplicationRecord
  paginates_per 50

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates_presence_of :description
  validate :fields_from_certificate_file, on: :create
  validates_inclusion_of :category, in: %w[EAP RADSEC]
  validates_uniqueness_of :filename, scope: :category
  validates_format_of :filename, with: /\A.+(.pem)+\z/
  validate :validate_server_certificate, on: :create

  def server_certificate?
    filename == "server.pem"
  end

  def validate_server_certificate
    return unless server_certificate?

    passphrase = case category
                 when "EAP"
                   ENV.fetch("EAP_SERVER_PRIVATE_KEY_PASSPHRASE")
                 when "RADSEC"
                   ENV.fetch("RADSEC_SERVER_PRIVATE_KEY_PASSPHRASE")
                 end

    validation_errors = UseCases::ValidateServerCertificate.new(certificate: contents).call(passphrase)

    validation_errors.each do |error|
      errors.add :base, error
    end
  end

private

  def fields_from_certificate_file
    unless expiry_date.present? && subject.present?
      errors.add :certificate, "is missing or invalid"
    end
  end

  # rubocop:disable Lint/IneffectiveAccessModifier
  def self.ransackable_attributes(auth_object = nil)
    ["category", "contents", "created_at", "description", "expiry_date", "extensions", "filename", "id", "issuer", "name", "serial", "subject", "updated_at"]
  end
  # rubocop:enable Lint/IneffectiveAccessModifier

  audited
end
