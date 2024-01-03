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

  describe "confirmed_director?" do
    subject(:user) { create(:user, :director) }

    it { is_expected.not_to be_confirmed_director }

    context "when the user has confirmed_director for its current establishment" do
      subject(:user) { create(:user, :confirmed_director) }

      it { is_expected.to be_confirmed_director }
    end

    context "when the user has confirmed_director for another establishment" do
      subject(:user) { create(:user, :confirmed_director) }

      before { user.update(establishment: create(:establishment)) }

      it { is_expected.not_to be_confirmed_director }
    end
  end
end
