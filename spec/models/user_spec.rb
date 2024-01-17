# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment").optional }
  end

  describe "validations" do
    %w[uid name email provider token secret email].each do |attr|
      it { is_expected.to validate_presence_of(attr) }
    end
  end

  describe "normalize email" do
    let(:user) { create(:user, email: "MyEmail@educagri.fr") }

    it "normalizes the email" do
      expect(user.email).to eq "myemail@educagri.fr"
    end
  end

  describe "can have the same email as another user from another provider" do
    subject(:user_masa) { create(:user, email: user_fim.email, provider: :masa) }

    let(:user_fim) { create(:user, provider: :fim) }

    it { is_expected.to be_valid }
  end

  describe "cannot have the same email as another user from the same provider" do
    subject(:user_masa) { build(:user, email: user_fim.email, provider: :fim) }

    let(:user_fim) { create(:user, provider: :fim) }

    it { is_expected.not_to be_valid }
  end

  describe "establishment" do
    let(:user) { create(:user, :director) }
    let(:other_establishment) { create(:establishment) }

    it "has to be part of the user's establishments" do
      expect { user.update!(establishment: other_establishment) }.to raise_error(/no corresponding roles/)
    end
  end
end
