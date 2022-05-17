module CreateCertificateHelpers
  def generate_self_signed_certificate
    key = OpenSSL::PKey::RSA.new(4096)
    public_key = key.public_key

    cipher = OpenSSL::Cipher::Cipher.new("AES-128-CBC")
    pass_phrase = "secret"
    key_with_passphrase = key.to_pem(cipher, pass_phrase)

    subject = "/C=BE/O=Test/OU=Test/CN=Test"

    cert = OpenSSL::X509::Certificate.new
    cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
    cert.not_before = Time.now
    cert.not_after = Time.now + 365 * 24 * 60 * 60
    cert.public_key = public_key
    cert.serial = 0x0
    cert.version = 2

    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = cert
    cert.extensions = [
      ef.create_extension("basicConstraints","CA:TRUE", true),
      ef.create_extension("subjectKeyIdentifier", "hash"),
    ]
    cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                          "keyid:always,issuer:always")

    cert.sign key, OpenSSL::Digest::SHA1.new

    {
      cert: cert.to_pem,
      key: key_with_passphrase,
      cert_and_key: cert.to_pem + "\n" + key_with_passphrase
    }
  end
end
