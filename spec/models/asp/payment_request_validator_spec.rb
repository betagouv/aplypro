# frozen_string_literal: true

require "rails_helper"
# rubocop:disable all
RSpec.describe ASP::PaymentRequestValidator do
  let(:validator) { described_class.new(payment_request) }
  let(:payment_request) { ASP::PaymentRequest.new }
  let(:student) { Student.new(birthdate: 18.years.ago.to_date) }
  let(:schooling) { Schooling.new }
  let(:pfmp) { Pfmp.new(start_date: Time.zone.today) }
  let(:rib) { Rib.new }
  let(:establishment) { Establishment.new(uai: "0123456X") }
  let(:mef) { Mef.new(code: "12345678") }
  let(:classe) { Classe.new }
  let(:school_year) { SchoolYear.new }

  before do
    allow(payment_request).to receive(:student).and_return(student)
    allow(payment_request).to receive(:schooling).and_return(schooling)
    allow(payment_request).to receive(:pfmp).and_return(pfmp)
    allow(payment_request).to receive(:rib).and_return(rib)

    allow(schooling).to receive(:establishment).and_return(establishment)
    allow(schooling).to receive(:mef).and_return(mef)
    allow(schooling).to receive(:classe).and_return(classe)
    allow(classe).to receive(:establishment).and_return(establishment)
    allow(classe).to receive(:mef).and_return(mef)
    allow(classe).to receive(:school_year).and_return(school_year)
  end

  describe "#check_student" do
    context "when biological sex is unknown" do
      before { allow(student).to receive(:sex_unknown?).and_return(true) }

      it "adds an error" do
        expect { validator.send(:check_student) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :missing_biological_sex))
      end
    end

    context "when INE is not found" do
      before { allow(student).to receive(:ine_not_found).and_return(true) }

      it "adds an error" do
        expect { validator.send(:check_student) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :ine_not_found))
      end
    end
  end

  describe "#check_insee_code" do
    context "when birthplace country INSEE code is blank" do
      before { allow(student).to receive(:birthplace_country_insee_code).and_return(nil) }

      it "adds an error" do
        expect { validator.send(:check_insee_code) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :missing_birthplace_country_insee_code))
      end
    end

    context "when birthplace country INSEE code is unusable" do
      before do
        allow(student).to receive(:birthplace_country_insee_code)
          .and_raise(InseeCountryCodeMapper::UnusableCountryCode)
      end

      it "adds an error" do
        expect { validator.send(:check_insee_code) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :unusable_birthplace_country_insee_code))
      end
    end

    context "when born in France and birthplace city INSEE code is blank" do
      before do
        allow(student).to receive(:born_in_france?).and_return(true)
        allow(student).to receive(:birthplace_city_insee_code).and_return(nil)
      end

      it "adds an error" do
        expect { validator.send(:check_insee_code) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :missing_birthplace_city_insee_code))
      end
    end
  end

  describe "#check_address" do
    context "when student lives in France" do
      before { allow(student).to receive(:lives_in_france?).and_return(true) }

      %i[address_postal_code address_city_insee_code address_country_code].each do |info|
        context "when #{info} is blank" do
          before { allow(student).to receive(info).and_return(nil) }

          it "adds an error" do
            expect { validator.send(:check_address) }
              .to change { payment_request.errors.details[:ready_state_validation] }
              .to include(a_hash_including(error: :"missing_#{info}"))
          end
        end
      end
    end
  end


  describe "#check_rib" do
    context "when RIB is missing" do
      before do
        allow(payment_request).to receive(:rib).and_return(nil)
        allow(student).to receive(:rib).and_return(nil)
      end

      it "adds an error" do
        expect { validator.send(:check_rib) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :missing_rib))
      end
    end

    context "when RIB is invalid" do
      before { allow(rib).to receive(:invalid?).and_return(true) }

      it "adds an error" do
        expect { validator.send(:check_rib) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :rib))
      end
    end

    context "when adult student has other person or moral person RIB" do
      before do
        allow(student).to receive(:adult_at?).and_return(true)
        allow(rib).to receive(:other_person?).and_return(true)
      end

      it "adds an error" do
        expect { validator.send(:check_rib) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :adult_wrong_owner_type))
      end
    end
  end

  describe "#check_pfmp" do
    context "when PFMP is invalid" do
      before { allow(pfmp).to receive(:valid?).and_return(false) }

      it "adds an error" do
        expect { validator.send(:check_pfmp) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :pfmp))
      end
    end

    context "when PFMP amount is not positive" do
      before { allow(pfmp).to receive(:amount).and_return(0) }

      it "adds an error" do
        expect { validator.send(:check_pfmp) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :pfmp_amount))
      end
    end

    context "when PFMP amount is nil" do
      before { allow(pfmp).to receive(:amount).and_return(nil) }

      it "adds an error" do
        expect { validator.send(:check_pfmp) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :pfmp_amount))
      end
    end
  end

  describe "#check_pfmp_overlaps" do
    context "when PFMP overlaps with validated PFMPs" do
      before do
        overlapping_pfmp = instance_double(Pfmp, in_state?: true)
        allow(pfmp).to receive(:overlaps).and_return([overlapping_pfmp])
      end

      it "adds an error" do
        expect { validator.send(:check_pfmp_overlaps) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :overlaps))
      end
    end
  end

  describe "#check_pfmp_dates" do
    context "when PFMP dates are outside schooling dates" do
      before { allow(pfmp).to receive(:within_schooling_dates?).and_return(false) }

      it "adds an error" do
        expect { validator.send(:check_pfmp_dates) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :pfmp_outside_schooling_dates))
      end
    end

    context "when PFMP dates are within schooling dates" do
      before { allow(pfmp).to receive(:within_schooling_dates?).and_return(true) }

      it "does not add an error" do
        expect { validator.send(:check_pfmp_dates) }
          .not_to change { payment_request.errors.details[:ready_state_validation] }
      end
    end
  end

  describe "#check_schooling" do
    context "when schooling is not for a student" do
      before { allow(schooling).to receive(:student?).and_return(false) }

      it "adds an error" do
        expect { validator.send(:check_schooling) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :student_type))
      end
    end

    context "when schooling is excluded" do
      before do
        allow(Exclusion).to receive(:excluded?).with(establishment.uai, mef.code, school_year).and_return(true)
      end

      it "adds an error" do
        expect { validator.send(:check_schooling) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :excluded_schooling))
      end
    end
  end

  describe "#check_da_attribution" do
    context "when attributive decision is not attached" do
      before do
        allow(schooling).to receive_message_chain(:attributive_decision, :attached?).and_return(false) # rubocop:disable RSpec/MessageChain
      end

      it "adds an error" do
        expect { validator.send(:check_da_attribution) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :missing_attributive_decision))
      end
    end
  end

  describe "#check_da_abrogation" do
    context "when student is transferred and schooling needs abrogated attributive decision" do
      let(:other_schooling) { instance_double(Schooling, nullified?: false) }
      let(:other_classe) { instance_double(Classe, school_year:) }

      before do
        allow(student).to receive(:transferred?).and_return(true)
        allow(schooling).to receive(:abrogated?).and_return(false)
        allow(pfmp).to receive(:within_schooling_dates?).and_return(true)
        allow(student).to receive_message_chain(:schoolings, :excluding).and_return([other_schooling])
        allow(other_schooling).to receive(:classe).and_return(other_classe)
      end

      it "adds an error" do
        expect { validator.send(:check_da_abrogation) }
          .to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :needs_abrogated_attributive_decision))
      end
    end

    context "when conditions for abrogation are not met" do
      before do
        allow(student).to receive(:transferred?).and_return(false)
      end

      it "does not add an error" do
        expect { validator.send(:check_da_abrogation) }
          .not_to change { payment_request.errors.details[:ready_state_validation] }
      end
    end


    context "when PFMP is not within schooling dates" do
      let(:other_schooling) { instance_double(Schooling, nullified?: false) }
      let(:other_classe) { instance_double(Classe, school_year:) }

      before do
        allow(student).to receive(:transferred?).and_return(true)
        allow(schooling).to receive(:abrogated?).and_return(false)
        allow(pfmp).to receive(:within_schooling_dates?).and_return(false)
        allow(student).to receive_message_chain(:schoolings, :excluding).and_return([other_schooling])
        allow(other_schooling).to receive(:classe).and_return(other_classe)
      end

      it "does not add an error" do
        expect { validator.send(:check_da_abrogation) }
          .not_to change { payment_request.errors.details[:ready_state_validation] }
      end
    end
  end

  describe "#validate" do
    it "calls all check methods" do
      expect(validator).to receive(:check_student)
      expect(validator).to receive(:check_insee_code)
      expect(validator).to receive(:check_address)
      expect(validator).to receive(:check_da_attribution)
      expect(validator).to receive(:check_da_cancellation)
      expect(validator).to receive(:check_da_abrogation)
      expect(validator).to receive(:check_rib)
      expect(validator).to receive(:check_pfmp)
      expect(validator).to receive(:check_pfmp_overlaps)
      expect(validator).to receive(:check_pfmp_dates)
      expect(validator).to receive(:check_schooling)
      validator.validate
    end
  end
end
# rubocop enable all
