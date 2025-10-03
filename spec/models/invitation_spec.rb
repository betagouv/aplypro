# frozen_string_literal: true

require "rails_helper"

RSpec.describe Invitation do
  describe "base class" do
    describe "associations" do
      it { is_expected.to belong_to(:establishment).optional }
      it { is_expected.to belong_to(:user) }
    end

    describe "validations" do
      it { is_expected.to validate_presence_of :email }
    end
  end

  describe EstablishmentInvitation do
    subject(:invitation) { build(:establishment_invitation) }

    describe "associations" do
      it { is_expected.to belong_to(:user) }
    end

    describe "validations" do
      it { is_expected.to validate_presence_of :email }

      it "requires establishment" do
        invitation.establishment = nil
        expect(invitation).not_to be_valid
        expect(invitation.errors[:establishment]).to be_present
      end

      describe "email uniqueness scoped to establishment" do
        let(:establishment) { create(:establishment) }

        it "validates uniqueness of email within same establishment (case insensitive)" do
          create(:establishment_invitation, email: "test@educagri.fr", establishment: establishment)
          new_invitation = build(:establishment_invitation, email: "TEST@educagri.fr", establishment: establishment)
          expect(new_invitation).not_to be_valid
          expect(new_invitation.errors[:email]).to be_present
        end

        it "allows same email for different establishments" do
          create(:establishment_invitation, email: "test@educagri.fr", establishment: establishment)
          other_establishment = create(:establishment)
          new_invitation = build(:establishment_invitation, email: "test@educagri.fr",
                                                            establishment: other_establishment)
          expect(new_invitation).to be_valid
        end
      end
    end

    describe "normalize email" do
      let(:invitation) { create(:establishment_invitation, email: "MyEmail@educagri.fr") }

      it "normalizes the email" do
        expect(invitation.email).to eq "myemail@educagri.fr"
      end
    end
  end

  describe AcademicInvitation do
    subject(:invitation) { build(:academic_invitation) }

    describe "associations" do
      it { is_expected.to belong_to(:user) }
    end

    describe "validations" do
      it { is_expected.to validate_presence_of :email }

      it "requires academy_codes" do
        invitation.academy_codes = nil
        expect(invitation).not_to be_valid
        expect(invitation.errors[:academy_codes]).to be_present
      end

      it "requires academy_codes not to be empty" do
        invitation.academy_codes = []
        expect(invitation).not_to be_valid
        expect(invitation.errors[:academy_codes]).to be_present
      end

      describe "email uniqueness within type" do
        it "validates uniqueness of email within AcademicInvitation type (case insensitive)" do
          create(:academic_invitation, email: "test@educagri.fr")
          new_invitation = build(:academic_invitation, email: "TEST@educagri.fr")
          expect(new_invitation).not_to be_valid
          expect(new_invitation.errors[:email]).to be_present
        end

        it "allows same email for different invitation types" do
          create(:academic_invitation, email: "test@educagri.fr")
          new_invitation = build(:establishment_invitation, email: "test@educagri.fr")
          expect(new_invitation).to be_valid
        end
      end
    end

    describe "normalize email" do
      let(:invitation) { create(:academic_invitation, email: "MyEmail@educagri.fr") }

      it "normalizes the email" do
        expect(invitation.email).to eq "myemail@educagri.fr"
      end
    end
  end
end
