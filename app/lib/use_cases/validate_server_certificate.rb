require "openssl"

module UseCases
  class ValidateServerCertificate
    def initialize(certificate:)
      @certificate = certificate
    end

    def call
      errors = []

      OpenSSL::PKey::RSA.new(@certificate)

      errors
    rescue OpenSSL::PKey::RSAError
      errors << "Certificate is missing a private key"
    end
  end
end
