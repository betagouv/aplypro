# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ClassesControllers" do
  let(:classe) { create(:classe) }
  let(:establishment) { classe.establishment }
  let(:user) { create(:user, :director, establishment: establishment) }

  before do
    sign_in(user)
  end

  describe "GET /index" do
    it "returns a list of classes" do
      get "/classes"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /classe" do
    before do
      get class_path(classe)
    end

    it { is_expected.to render_template(:show) }

    context "when the classe doesn't belong to the establishment of the user" do
      before do
        get class_path(create(:classe))
      end

      it { is_expected.to redirect_to classes_path }
    end
  end
end
