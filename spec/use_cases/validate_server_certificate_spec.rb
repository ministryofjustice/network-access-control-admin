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

    it "fails validation" do
      expect(use_case.call).to include("Certificate does not contain a valid private key, see #{Rails.application.config.server_certificate_documentation}")
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

    it "fails validation" do
      expect(use_case.call("invalidpassphrase")).to include("Certificate does not contain a valid private key, see #{Rails.application.config.server_certificate_documentation}")
    end
  end

  context "when the private key does not match the certificate" do
    let(:invalid_certificate_path) { "./spec/acceptance/certificate/dummy_certificate/server_certificate/invalid_certificate.pem" }

    before do
      File.open(invalid_certificate_path, "w") { |f| f.write(generate_self_signed_certificate.fetch(:cert_and_invalid_key)) }
    end

    subject(:use_case) do
      described_class.new(
        certificate: File.read(invalid_certificate_path),
      )
    end

    it "fails validation" do
      expect(use_case.call(ENV.fetch("EAP_SERVER_PRIVATE_KEY_PASSPHRASE"))).to include("Certificate does not contain a matching private key, see #{Rails.application.config.server_certificate_documentation}")
    end
  end
end
