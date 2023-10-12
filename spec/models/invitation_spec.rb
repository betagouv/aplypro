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

  context "when the email ends with an authorised domain" do
    subject(:invitation) { build(:invitation, email: "user@education.gouv.fr.gmail.com") }

    it { is_expected.not_to be_valid }
  end
end
