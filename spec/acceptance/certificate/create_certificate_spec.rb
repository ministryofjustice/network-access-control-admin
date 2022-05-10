require "rails_helper"

describe "create certificates", type: :feature do
  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    context "when uploading a new certificate" do
      it "does upload a new valid certificate" do
        visit "/certificates"

        click_on "Upload a new certificate"

        expect(current_path).to eql("/certificates/new")

        select "EAP", from: "certificate_category"
        fill_in "Name", with: "My Test Certificate"
        fill_in "Description", with: "My test certificate description details"
        attach_file("Certificate", "spec/acceptance/certificate/dummy_certificate/mytestcertificate.pem")

        click_on "Upload"

        expect(page).to have_content("EAP")
        expect(page).to have_content("Successfully uploaded certificate.")
        expect(page).to have_content("My Test Certificate")
        expect(page).to have_content("mytestcertificate.pem")

        expect_audit_log_entry_for(editor.email, "create", "Certificate")
      end
      context "when a server certificate includes a valid private key" do 
        it "does upload a server certificate" do
          visit "/certificates"
  
          click_on "Upload a new certificate"
  
          select "EAP", from: "certificate_category"
          check "Server certificate"
          fill_in "Name", with: "My Test Server Certificate 2"
          fill_in "Description", with: "My test server certificate description details 2"
          attach_file("Certificate", "spec/acceptance/certificate/dummy_certificate/mytestcertificate.pem")
  
          click_on "Upload"
  
          expect(page).to have_content("EAP")
          expect(page).to have_content("Successfully uploaded certificate.")
          expect(page).to have_content("My Test Server Certificate 2")
          expect(page).to have_content("My test server certificate description details 2")
          expect(page).to have_content("Server certificate")
          expect(page).to have_content("Yes")
          expect(page).to have_content("17/07/2021 00:00")
          expect(page).to have_content("server.pem")
  
          expect_audit_log_entry_for(editor.email, "create", "Certificate")
        end
      end
    end

    it "displays error if form cannot be submitted" do
      visit "/certificates/new"

      click_on "Upload"

      expect(page).to have_content "There is a problem"
      expect(page).to have_content "Description can't be blank"
      expect(page).to have_content "Name can't be blank"
      expect(page).to have_content "Certificate is missing or invalid"
      expect(page).to_not have_content "Expiry date can't be blank"
      expect(page).to_not have_content "Subject can't be blank"
    end

    context "if the certificate is corrupted" do
      it "displays error when the certificate is invalid" do
        visit "/certificates/new"

        fill_in "Name", with: "My Test Certificate"
        fill_in "Description", with: "My test certificate description details"
        attach_file("Certificate", "spec/acceptance/certificate/dummy_certificate/invalid_certificate")

        click_on "Upload"

        expect(page).to have_content "There is a problem"
        expect(page).to have_content "Certificate is missing or invalid"
      end
      context "when the certificate is a server certificate" do 
        context "when the certificate is missing a private key" do
          before do
            `openssl req -x509 -newkey rsa:4096 -out ./spec/acceptance/certificates/dummy_certificate/server_missing_cert.pem -sha256 -days 1 -passout pass:whatever -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"`
          end
          it "displays an error message to the user" do
            visit "/certificates/new"
    
            check "Server certificate"
            fill_in "Name", with: "My Test Certificate"
            fill_in "Description", with: "My test certificate description details"
            attach_file("Certificate", "/spec/acceptance/certificate/dummy_certificate/server_missing_cert.pem")
    
            click_on "Upload"
    
            expect(page).to have_content "There is a problem"
            expect(page).to have_content "Certificate is missing a private key"
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
  end
end
