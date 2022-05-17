require "openssl"

module UseCases
  class ValidateServerCertificate
    def initialize(certificate:)
      @certificate = certificate
    end

    def call(passphrase = nil)
      unless OpenSSL::X509::Certificate.new(@certificate).check_private_key(OpenSSL::PKey::RSA.new(@certificate, passphrase))
        return ["Certificate does not contain a matching private key, see #{Rails.application.config.server_certificate_documentation}"]
      end

      []
    rescue OpenSSL::PKey::RSAError
      ["Certificate does not contain a valid private key, see #{Rails.application.config.server_certificate_documentation}"]
    end
  end
end
