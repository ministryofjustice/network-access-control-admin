require "openssl"

module UseCases
  class ValidateServerCertificate
    def initialize(certificate:)
      @certificate = certificate
      @errors = []
    end

    def call(passphrase = nil)
      check_certificate_contains_valid_private_key(passphrase)
      
      @errors
    end

    private

    def check_certificate_contains_valid_private_key(passphrase)
      OpenSSL::PKey::RSA.new(@certificate, passphrase)
    rescue OpenSSL::PKey::RSAError
      @errors << "Certificate does not contain a valid private key"
    end
  end
end
