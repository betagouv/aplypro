# frozen_string_literal: true

require "rails_helper"

RSpec.describe Invitation do
  subject(:invitation) { build(:invitation) }

  describe "associations" do
    it { is_expected.to belong_to(:establishment) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:establishment_id) }
  end

  describe "valid domains" do
    %w[
      test@gouv.fr
      test@education.gouv.fr
      test@educagri.fr
      test@ac-montpellier.fr
      test@sub.ac-montpellier.fr
      test@sub.educagri.fr
    ].each do |email|
      it "allows `#{email}`" do
        expect(build(:invitation, email: email)).to be_valid
      end
    end
  end

  describe "invalid domains" do
    %w[
      test@legouv.fr
      test@educagri.io.fr
      test@ac-perpignan.fr
      test@academie-montpellier.fr
    ].each do |email|
      it "does not allow `#{email}`" do
        expect(build(:invitation, email: email)).not_to be_valid
      end
    end
  end
end
