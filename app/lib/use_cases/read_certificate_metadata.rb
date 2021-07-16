require "openssl"

module UseCases
  class ReadCertificateMetadata
    def initialize(certificate:)
      @certificate = certificate
    end

    def call
      decoded_certificate = OpenSSL::X509::Certificate.new(certificate)
      {
        expiry_date: decoded_certificate.not_after.to_date,
        subject: decoded_certificate.subject.to_s,
      }
    end

  private

    attr_reader :certificate
  end
end
