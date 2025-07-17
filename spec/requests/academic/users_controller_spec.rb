# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::UsersController do
  let(:user) { create(:academic_user) }

  before do
    sign_in(user)
    allow_any_instance_of(described_class).to receive(:authorised_academy_codes).and_return(["01"]) # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:selected_academy).and_return("01") # rubocop:disable RSpec/AnyInstance
  end

  describe "GET index" do
    it "returns success" do
      get academic_users_path

      expect(response).to have_http_status(:success)
    end
  end
end
