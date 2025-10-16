# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::User do
  describe "validations" do
    %w[uid name email provider].each do |attr|
      it { is_expected.to validate_presence_of(attr) }
    end
  end

  it_behaves_like "a trackable user", :academic_user

  describe "#admin?" do
    subject(:academic_user) { build(:academic_user, oidc_attributes: oidc_attributes) }

    context "when oidc_attributes are blank" do
      let(:oidc_attributes) { nil }

      it "returns false" do
        expect(academic_user.admin?).to be false
      end
    end

    context "when AplyproAcademieResp contains a star" do
      let(:oidc_attributes) do
        {
          "extra" => {
            "raw_info" => {
              "AplyproAcademieResp" => ["*"]
            }
          }
        }
      end

      it "returns true" do
        expect(academic_user.admin?).to be true
      end
    end

    context "when AplyproAcademieResp contains multiple academies including a star" do
      let(:oidc_attributes) do
        {
          "extra" => {
            "raw_info" => {
              "AplyproAcademieResp" => ["01", "*", "02"]
            }
          }
        }
      end

      it "returns true" do
        expect(academic_user.admin?).to be true
      end
    end

    context "when AplyproAcademieResp does not contain a star" do
      let(:oidc_attributes) do
        {
          "extra" => {
            "raw_info" => {
              "AplyproAcademieResp" => %w[01 02]
            }
          }
        }
      end

      it "returns false" do
        expect(academic_user.admin?).to be false
      end
    end

    context "when AplyproAcademieResp is empty" do
      let(:oidc_attributes) do
        {
          "extra" => {
            "raw_info" => {
              "AplyproAcademieResp" => []
            }
          }
        }
      end

      it "returns false" do
        expect(academic_user.admin?).to be false
      end
    end
  end
end
