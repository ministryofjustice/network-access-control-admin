require "rails_helper"

describe UseCases::ReadCertificateMetadata do
  let(:certificate) { File.read "spec/acceptance/certificate/dummy_certificate/mytestcertificate.pem" }

  subject(:use_case) do
    described_class.new(
      certificate: certificate,
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
end
