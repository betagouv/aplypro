# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rib do
  subject(:rib) { create(:rib) }

  describe "associations" do
    it { is_expected.to belong_to(:student) }
    it { is_expected.to have_many(:payment_requests) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:iban) }
    it { is_expected.to validate_presence_of(:bic) }
    it { is_expected.to validate_presence_of(:name) }

    it {
      expect(rib).to validate_uniqueness_of(:student_id).scoped_to(:archived_at, :establishment_id)
                                                        .with_message(:unarchivable_rib)
    }

    context "when the IBAN is from outside the SEPA zone" do
      subject(:rib) { build(:rib, iban: Faker::Bank.iban(country_code: "br")) }

      it { is_expected.not_to be_valid }
    end

    context "when the student has been in multiple establishments" do
      let(:student) { create(:student) }
      let(:establishment1) { create(:establishment) }
      let(:establishment2) { create(:establishment) }

      before do
        create(:rib, student: student, establishment: establishment1)
        create(:rib, student: student, establishment: establishment2)
      end

      it "allows multiple active RIBs for different establishments" do
        new_rib = build(:rib, student: student, establishment: create(:establishment))
        expect(new_rib).to be_valid
      end

      it "doesn't allow multiple active RIBs for the same establishment" do
        new_rib = build(:rib, student: student, establishment: establishment1)
        expect(new_rib).not_to be_valid
        expect(new_rib.errors[:student_id]).to include(I18n.t("activerecord.errors.models.rib.attributes.student_id.unarchivable_rib"))
      end

      it "allows a new RIB for an establishment if the previous one is archived" do
        student.ribs.find_by(establishment: establishment1).archive!
        new_rib = build(:rib, student: student, establishment: establishment1)
        expect(new_rib).to be_valid
      end
    end

    context "when there are extra spaces" do
      before { rib.iban = "     #{rib.iban}" }

      it "validates despite them" do
        expect(rib).to be_valid
      end
    end

    context "when it's lowercased" do
      before { rib.iban = rib.iban.downcase }

      it "validates anyway" do
        expect(rib).to be_valid
      end
    end
  end

  describe "normalization" do
    subject(:spaced) do
      create(
        :rib,
        bic: "   #{"#{rib.bic.downcase[0..2]}   #{rib.bic[3..]}"}  ",
        iban: "   #{"#{rib.iban.downcase[0..2]}  #{rib.iban[3..]}"}\t  "
      )
    end

    %i[bic iban].each do |attr|
      it "strips the #{attr}" do
        expect(spaced[attr]).to eq rib[attr].upcase
      end
    end

    describe "name" do
      it "squishes the name attribute" do
        rib = create(:rib, name: "     Marie\t\tCurie     Mrs  ")

        expect(rib.name).to eq "Marie Curie Mrs"
      end
    end
  end

  context "when there is an ongoing payment request" do
    let(:rib) { create(:asp_payment_request, :sent).student.rib }

    it "is marked as readonly" do
      expect(rib).to be_readonly
    end
  end
end
