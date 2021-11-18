require "openssl"

module UseCases
  class ReadCertificateMetadata
    def initialize(certificate:)
      @certificate = certificate
    end

    def call
      decoded_certificate = OpenSSL::X509::Certificate.new(certificate)

      extensions = decoded_certificate.extensions.map do |extension|
        "#{extension.oid}:#{' critical' if extension.critical?}\n\t#{extension.value}"
      end

      {
        expiry_date: decoded_certificate.not_after.to_date,
        subject: decoded_certificate.subject.to_s,
        issuer: decoded_certificate.issuer.to_s,
        serial: decoded_certificate.serial.to_s,
        extensions: extensions.join("\n\n"),
      }
    rescue StandardError
      {}
    end

  private

    attr_reader :certificate
  end
end
