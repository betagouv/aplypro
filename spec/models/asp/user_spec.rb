# frozen_string_literal: true

require "rails_helper"

RSpec.describe ASP::User do
  describe "validations" do
    %w[uid name email provider].each do |attr|
      it { is_expected.to validate_presence_of(attr) }
    end

    describe "email" do
      subject { user }

      let(:user) { described_class.new(uid: "foo", name: "bar", provider: "asp", email: email) }

      context "when the email is neither 'asp-public.fr' nor 'asp.gouv.fr'" do
        let(:email) { "test@gmail.com" }

        it { is_expected.not_to be_valid }
      end

      context "when the email is 'asp-public.fr'" do
        let(:email) { "test@asp-public.fr" }

        it { is_expected.to be_valid }
      end

      context "when the email is 'asp.gouv.fr'" do
        let(:email) { "test@asp.gouv.fr" }

        it { is_expected.to be_valid }
      end
    end
  end
end
