require "rails_helper"

describe "create certificates", type: :feature do
  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    context "when uploading a new certificate" do
      context "when a server certificate includes a valid private key" do
        let(:valid_certificate_path) { "./spec/acceptance/certificate/dummy_certificate/server_certificate/valid_certificate.pem" }

        before do
          File.open(valid_certificate_path, "w") { |f| f.write(generate_self_signed_certificate.fetch(:cert_and_key)) }
        end
        it "does upload a server certificate" do
          visit "/certificates"

          click_on "Upload a new certificate"

          select "EAP", from: "certificate_category"
          check "Server certificate"
          fill_in "Name", with: "My Test Server Certificate 2"
          fill_in "Description", with: "My test server certificate description details 2"
          attach_file("Certificate", valid_certificate_path)

          click_on "Upload"

          expect(page).to have_content("EAP")
          expect(page).to have_content("Successfully uploaded certificate.")
          expect(page).to have_content("My Test Server Certificate 2")
          expect(page).to have_content("My test server certificate description details 2")
          expect(page).to have_content("Server certificate")
          expect(page).to have_content("Yes")
          expect(page).to have_content("server.pem")

          expect_audit_log_entry_for(editor.email, "create", "Certificate")
        end
      end
    end

    context "when the certificate is missing a private key" do
      let(:cert_missing_private_key_path) { "./spec/acceptance/certificate/dummy_certificate/server_certificate/cert_missing_private_key.pem" }

      before do
        File.open(cert_missing_private_key_path, "w") { |f| f.write(generate_self_signed_certificate.fetch(:cert)) }
      end

      it "displays an error message to the user" do
        visit "/certificates/new"

        check "Server certificate"
        fill_in "Name", with: "My Test Certificate"
        fill_in "Description", with: "My test certificate description details"
        attach_file("Certificate", cert_missing_private_key_path)

        click_on "Upload"

        expect(page).to have_content "There is a problem"
        expect(page).to have_content "Certificate does not contain a valid private key"
      end
    end

    context "when the passphrase for the private key doesn't match" do
      context "when the category is EAP" do
        let(:valid_certificate_path) { "./spec/acceptance/certificate/dummy_certificate/server_certificate/valid_certificate.pem" }

        before do
          ENV['EAP_SERVER_PRIVATE_KEY_PASSPHRASE'] = "notwhatever"

          File.open(valid_certificate_path, "w") { |f| f.write(generate_self_signed_certificate.fetch(:cert_and_key)) }
        end

        it "displays an error message to the user" do
          visit "/certificates/new"

          check "Server certificate"
          fill_in "Name", with: "My Test Certificate"
          fill_in "Description", with: "My test certificate description details"
          attach_file("Certificate", valid_certificate_path)

          click_on "Upload"

          expect(page).to have_content "There is a problem"
          expect(page).to have_content "Certificate does not contain a valid private key"
        end
      end

      context "when the category is RADSEC" do
        let(:valid_certificate_path) { "./spec/acceptance/certificate/dummy_certificate/server_certificate/valid_certificate.pem" }

        before do
          ENV['RADSEC_SERVER_PRIVATE_KEY_PASSPHRASE'] = "notwhatever"

          File.open(valid_certificate_path, "w") { |f| f.write(generate_self_signed_certificate.fetch(:cert_and_key)) }
        end

        it "displays an error message to the user" do
          visit "/certificates/new"

          select "RADSEC", from: "certificate_category"
          check "Server certificate"
          fill_in "Name", with: "My Test Certificate"
          fill_in "Description", with: "My test certificate description details"
          attach_file("Certificate", valid_certificate_path)

          click_on "Upload"

          expect(page).to have_content "There is a problem"
          expect(page).to have_content "Certificate does not contain a valid private key"
        end
      end
    end

    context "when the certificate has a private key but it doesn't match the certificate" do
      it "displays an error message to the user" do
        visit "/certificates/new"

        check "Server certificate"
        fill_in "Name", with: "My Test Certificate"
        fill_in "Description", with: "My test certificate description details"
        attach_file("Certificate", "spec/acceptance/certificate/dummy_certificate/invalid_certificate")

        click_on "Upload"

        expect(page).to have_content "There is a problem"
        expect(page).to have_content "Private Key does not match the certificate"
      end
    end
  end
end
