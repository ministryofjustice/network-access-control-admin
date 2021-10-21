RSpec.shared_examples "response view" do |domain, response|
  context "when the user is authenticated" do
    before do
      login_as create(:user, :reader)
    end

    context "when a domain exists with a response" do
      let!(:created_domain) { create domain }
      let!(:created_response) { create(response, { domain => created_domain }) }

      it "allows viewing responses on the domain page" do
        visit "/#{domain.to_s.pluralize}/#{created_domain.id}"

        expect(page).to have_content created_domain.name
        expect(page).to have_content created_domain.description
        expect(page).to have_content created_response.response_attribute
        expect(page).to have_content created_response.value
      end
    end

    context "when a domain exists without responses" do
      let!(:created_domain) { create domain }

      it "does not show the responses table" do
        visit "/#{domain.to_s.pluralize}/#{created_domain.id}"

        expect(page).to have_content created_domain.name
        expect(page).to have_content created_domain.description
        expect(page).to_not have_content "List of responses"
      end
    end
  end
end
