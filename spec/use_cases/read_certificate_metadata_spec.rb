require "rails_helper"

describe UseCases::ReadCertificateMetadata do
  context "when the certificate is valid" do
    let(:certificate) { File.read "spec/acceptance/certificate/dummy_certificate/mytestcertificate.pem" }

    subject(:use_case) do
      described_class.new(
        certificate:,
      )
    end

    it "extracts the expiry date of the certificate" do
      expiration_date = use_case.call[:expiry_date]
      expected_date = "17 Jul 2021".to_date
      expect(expiration_date.to_date).to eq expected_date
    end

    it "extracts the subject of the certificate" do
      subject = use_case.call[:subject]
      expected_subject = "/C=GB/ST=London/L=London/O=MoJ/OU=MoJ/CN=MoJTestCert/emailAddress=testcert@moj.gov.uk"
      expect(subject).to eq expected_subject
    end

    it "extracts the issuer of the certificate" do
      issuer = use_case.call[:issuer]
      expected_issuer = "/C=GB/ST=London/L=London/O=MoJ/OU=MoJ/CN=MoJTestCert/emailAddress=testcert@moj.gov.uk"
      expect(issuer).to eq expected_issuer
    end

    it "extracts the serial of the certificate" do
      serial = use_case.call[:serial]
      expected_serial = "261449075976929706890225671845538541127278523818"
      expect(serial).to eq expected_serial
    end

    it "extracts the extensions of the certificate" do
      extensions = use_case.call[:extensions]
      expected_extensions = <<~EXTENSIONS
        subjectKeyIdentifier:
        \t46:53:FE:BC:50:C0:5D:02:B5:24:1B:BA:B3:B8:E2:89:87:85:40:08

        authorityKeyIdentifier:
        \tkeyid:46:53:FE:BC:50:C0:5D:02:B5:24:1B:BA:B3:B8:E2:89:87:85:40:08


        basicConstraints: critical
        \tCA:TRUE
      EXTENSIONS

      puts "Actual extensions: #{extensions.inspect}"
      puts "Expected extensions: #{expected_extensions.strip.inspect}"

      expect(extensions).to eq expected_extensions.strip
    end
  end

  context "when the certificate is invalid" do
    let(:invalid_certificate) { File.read "spec/acceptance/certificate/dummy_certificate/invalid_certificate" }

    subject(:use_case) do
      described_class.new(
        certificate: invalid_certificate,
      )
    end

    it "can handle invalid certificates" do
      expect(use_case.call).to eq({})
    end
  end
end
