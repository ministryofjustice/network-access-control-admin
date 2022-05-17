require "openssl"

module UseCases
  class ValidateServerCertificate
    def initialize(certificate:)
      @certificate = certificate
      @errors = []
    end

    def call
      check_certificate_contains_private_key
      # check_certificate_passphrase
      
      @errors
    end

    private

    def check_certificate_contains_private_key
      OpenSSL::PKey::RSA.new(@certificate)
    rescue OpenSSL::PKey::RSAError
      @errors << "Certificate is missing a private key"
    end

    def check_certificate_passphrase
      OpenSSL::PKey::RSA.new(@certificate, "secret")
    rescue OpenSSL::PKey::RSAError
      @errors << "Certificate passphrase does not match"
    end
  end
end
