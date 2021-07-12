require "rails_helper"

describe User, type: :model do
  describe ".from_omniauth" do
    subject(:user) { User.from_omniauth(auth_hash) }
    let(:role) { "" }
    let(:auth_hash) do
      # Mocking OmniAuth::AuthHash
      double(provider: "cognito", uid: "1",
             extra: double(raw_info: { "custom:app_role" => role, :identities => [double(userId: "test_from_omniauth@example.com")] }))
    end

    context "editor app role" do
      let(:role) { "editor" }

      it "sets editor to true" do
        expect(user.editor?).to eq true
      end
    end

    context "viewer app role" do
      let(:role) { "viewer" }

      it "sets editor to false" do
        expect(user.editor?).to eq false
      end
    end

    it "sets the email correctly" do
      expect(user.email).to eq "test_from_omniauth@example.com"
    end
  end
end
