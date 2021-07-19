require "rails_helper"

describe "update certificate", type: :feature do
    let!(:certificate) do
        create(:certificate)
    end

    context "when the user is unauthenticated" do
        it "does not allow updating certificates" do
          visit "/certificates/#{certificate.to_param}/edit"
    
          expect(page).to have_content "You need to sign in or sign up before continuing."
        end
      end
    
      context "when the user is a viewer" do
        before do
          login_as create(:user, :reader)
        end
    
        it "does not allow editing certificates" do
          visit "/certificates"
    
          expect(page).not_to have_content "Change"
    
          visit "/certificates/#{certificate.to_param}/edit"
    
          expect(page).to have_content "You are not authorized to access this page."
        end
      end

    context "when the user is an editor" do
        let(:editor) { create(:user, :editor) }

        before do
            login_as editor
        end

        it "does update an existing certificate" do
            visit "/certificates"

            first(:link, "Change").click

            expect(page).to have_field("Name", with: certificate.name)
            expect(page).to have_field("Description", with: certificate.description)
            
            fill_in "Name", with: "New Certificate Updated Name"
            fill_in "Description", with: "New Certificate Updated Description"

            click_on "Update"

            expect(current_path).to eq("/certificates/#{certificate.to_param}")

            expect(page).to have_content("New Certificate Updated Name")
            expect(page).to have_content("Successfully updated certificate details.")
      
            expect_audit_log_entry_for(editor.email, "update", "Certificate")
      
        end
    end
end