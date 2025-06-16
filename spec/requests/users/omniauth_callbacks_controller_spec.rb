# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController do
  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:fim] = nil
  end

  describe "GET #fim" do
    before do
      OmniAuth.config.mock_auth[:fim] = OmniAuth::AuthHash.new(
        provider: "fim",
        uid: "123",
        info: {
          email: "test@example.com",
          name: "Test User"
        },
        credentials: {
          token: "mock_token"
        },
        extra: {
          raw_info: {
            sub: "123",
            email: "test@example.com",
            FrEduRne: ["0123456X$UAJ$PU$ADM$111$T3$LYC$340"]
          }
        }
      )
    end

    it "handles successful authentication" do
      expect do
        get "/users/auth/fim/callback"
      end.to change(User, :count).by(1)

      expect(response).to redirect_to("/login")
    end
  end

  describe "GET #fim with invalid auth" do
    before do
      OmniAuth.config.mock_auth[:fim] = :invalid_credentials
    end

    it "redirects to failure path when authentication fails" do
      get "/users/auth/fim/callback"
      expect(response).to redirect_to("/users/auth/failure?message=invalid_credentials&strategy=fim")
    end
  end

  describe "GET #fim with existing user for an email" do
    before do
      User.create!(
        provider: "fim",
        uid: "original_uid",
        email: "existing@example.com",
        name: "Original Name",
        token: "original_token",
        secret: "nope"
      )

      OmniAuth.config.mock_auth[:fim] = OmniAuth::AuthHash.new(
        provider: "fim",
        uid: "new_uid",
        info: {
          email: "existing@example.com",
          name: "Updated Name"
        },
        credentials: {
          token: "nope2"
        },
        extra: {
          raw_info: {
            sub: "new_uid",
            email: "existing@example.com",
            FrEduRne: ["0123456X$UAJ$PU$ADM$111$T3$LYC$340"]
          }
        }
      )
    end

    it "updates existing user instead of creating new one" do # rubocop:disable RSpec/ExampleLength
      expect do
        get "/users/auth/fim/callback"
      end.not_to change(User, :count)

      user = User.find_by(email: "existing@example.com", provider: "fim")
      expect(user.token).to eq("nope2")
      expect(user.name).to eq("Updated Name")
      expect(user.uid).to eq("new_uid")
    end
  end
end
