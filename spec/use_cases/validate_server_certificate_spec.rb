require "rails_helper"

describe UseCases::ValidateServerCertificate do
  context "when the certificate is invalid" do
    let(:cert_missing_private_key_path) { "./spec/acceptance/certificate/dummy_certificate/server_certificate/cert_missing_private_key.pem" }

    before do
      File.open(cert_missing_private_key_path, "w") { |f| f.write(generate_self_signed_certificate.fetch(:cert)) }
    end

    subject(:use_case) do
      described_class.new(
        certificate: File.read("spec/acceptance/certificate/dummy_certificate/server_certificate/cert_missing_private_key.pem"),
      )
    end

    it "can handle invalid certificates" do
      expect(use_case.call).to include("Certificate is missing a private key")
    end
  end

  context "when the passphrase does not match" do

    let(:valid_certificate_path) { "./spec/acceptance/certificate/dummy_certificate/server_certificate/valid_certificate.pem" }

    before do
      File.open(valid_certificate_path, "w") { |f| f.write(generate_self_signed_certificate.fetch(:cert_and_key)) }
    end

    subject(:use_case) do
      described_class.new(
        certificate: File.read(valid_certificate_path),
      )
    end

    it "can handle incorrect passphrase" do
      expect(use_case.call).to include("Certificate passphrase does not match")
    end
  end
end