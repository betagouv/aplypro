# frozen_string_literal: true

require "rails_helper"
# rubocop:disable RSpec/MultipleMemoizedHelpers
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

  before do
    allow(payment_request).to receive(:student).and_return(student) # rubocop:disable RSpec/ReceiveMessages
    allow(payment_request).to receive(:schooling).and_return(schooling) # rubocop:disable RSpec/ReceiveMessages
    allow(payment_request).to receive(:pfmp).and_return(pfmp) # rubocop:disable RSpec/ReceiveMessages
    allow(payment_request).to receive(:rib).and_return(rib) # rubocop:disable RSpec/ReceiveMessages

    allow(schooling).to receive(:establishment).and_return(establishment) # rubocop:disable RSpec/ReceiveMessages
    allow(schooling).to receive(:mef).and_return(mef) # rubocop:disable RSpec/ReceiveMessages
    allow(schooling).to receive(:classe).and_return(classe) # rubocop:disable RSpec/ReceiveMessages
    allow(classe).to receive(:establishment).and_return(establishment) # rubocop:disable RSpec/ReceiveMessages
    allow(classe).to receive(:mef).and_return(mef) # rubocop:disable RSpec/ReceiveMessages
  end

  describe "#check_student" do
    it "adds an error if biological sex is unknown" do
      allow(student).to receive(:sex_unknown?).and_return(true)
      expect do
        validator.send(:check_student)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :missing_biological_sex))
    end

    it "adds an error if INE is not found" do
      allow(student).to receive(:ine_not_found).and_return(true)
      expect do
        validator.send(:check_student)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :ine_not_found))
    end
  end

  describe "#check_insee_code" do
    it "adds an error if birthplace country INSEE code is blank" do
      allow(student).to receive(:birthplace_country_insee_code).and_return(nil)
      expect do
        validator.send(:check_insee_code)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :missing_birthplace_country_insee_code))
    end

    it "adds an error if born in France and birthplace city INSEE code is blank" do # rubocop:disable RSpec/ExampleLength
      allow(student).to receive(:born_in_france?).and_return(true) # rubocop:disable RSpec/ReceiveMessages
      allow(student).to receive(:birthplace_city_insee_code).and_return(nil) # rubocop:disable RSpec/ReceiveMessages
      expect do
        validator.send(:check_insee_code)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :missing_birthplace_city_insee_code))
    end
  end

  describe "#check_address" do
    %i[address_postal_code address_city_insee_code address_country_code].each do |info|
      it "adds an error if #{info} is blank" do
        allow(student).to receive(info).and_return(nil)
        expect do
          validator.send(:check_address)
        end.to change { payment_request.errors.details[:ready_state_validation] }
          .to include(a_hash_including(error: :"missing_#{info}"))
      end
    end
  end

  describe "#check_rib" do
    it "adds an error if RIB is missing" do # rubocop:disable RSpec/ExampleLength
      allow(payment_request).to receive(:rib).and_return(nil)
      allow(student).to receive(:rib).and_return(nil)
      expect do
        validator.send(:check_rib)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :missing_rib))
    end

    it "adds an error if RIB is invalid" do
      allow(rib).to receive(:invalid?).and_return(true)
      expect do
        validator.send(:check_rib)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :rib))
    end

    it "adds an error if adult student has other person or moral person RIB" do # rubocop:disable RSpec/ExampleLength
      allow(student).to receive(:adult_at?).and_return(true)
      allow(rib).to receive(:other_person?).and_return(true)
      expect do
        validator.send(:check_rib)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :adult_wrong_owner_type))
    end
  end

  describe "#check_pfmp" do
    it "adds an error if PFMP is invalid" do
      allow(pfmp).to receive(:valid?).and_return(false)
      expect do
        validator.send(:check_pfmp)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :pfmp))
    end

    it "adds an error if PFMP amount is not positive" do
      allow(pfmp).to receive(:amount).and_return(0)
      expect do
        validator.send(:check_pfmp)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :pfmp_amount))
    end

    it "adds an error if PFMP amount is nil" do
      allow(pfmp).to receive(:amount).and_return(nil)
      expect do
        validator.send(:check_pfmp)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :pfmp_amount))
    end
  end

  describe "#check_pfmp_overlaps" do
    it "adds an error if PFMP overlaps with validated PFMPs" do # rubocop:disable RSpec/ExampleLength
      overlapping_pfmp = instance_double(Pfmp, in_state?: true)
      allow(pfmp).to receive(:overlaps).and_return([overlapping_pfmp])
      expect do
        validator.send(:check_pfmp_overlaps)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :overlaps))
    end
  end

  describe "#check_schooling" do
    it "adds an error if schooling is not for a student" do
      allow(schooling).to receive(:student?).and_return(false)
      expect do
        validator.send(:check_schooling)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :student_type))
    end

    it "adds an error if schooling is excluded" do
      allow(Exclusion).to receive(:excluded?).with(establishment.uai, mef.code).and_return(true)
      expect do
        validator.send(:check_schooling)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :excluded_schooling))
    end
  end

  describe "#check_da_attribution" do
    it "adds an error if attributive decision is not attached" do
      allow(schooling).to receive_message_chain(:attributive_decision, :attached?).and_return(false) # rubocop:disable RSpec/MessageChain
      expect do
        validator.send(:check_da_attribution)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :missing_attributive_decision))
    end
  end

  describe "#check_da_abrogation" do
    it "adds an error if student transferred and schooling needs abrogated attributive decision" do # rubocop:disable RSpec/ExampleLength
      allow(student).to receive(:transferred?).and_return(true)
      allow(schooling).to receive(:abrogated?).and_return(false)
      allow(pfmp).to receive(:within_schooling_dates?).and_return(true)
      allow(student).to receive_message_chain(:schoolings, :excluding, :all?).and_return(false) # rubocop:disable RSpec/MessageChain
      expect do
        validator.send(:check_da_abrogation)
      end.to change { payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: :needs_abrogated_attributive_decision))
    end
  end

  describe "#validate" do
    it "calls all check methods" do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      expect(validator).to receive(:check_student) # rubocop:disable RSpec/MessageSpies
      expect(validator).to receive(:check_insee_code) # rubocop:disable RSpec/MessageSpies
      expect(validator).to receive(:check_address) # rubocop:disable RSpec/MessageSpies
      expect(validator).to receive(:check_da_attribution) # rubocop:disable RSpec/MessageSpies
      expect(validator).to receive(:check_da_abrogation) # rubocop:disable RSpec/MessageSpies
      expect(validator).to receive(:check_rib) # rubocop:disable RSpec/MessageSpies
      expect(validator).to receive(:check_pfmp) # rubocop:disable RSpec/MessageSpies
      expect(validator).to receive(:check_pfmp_overlaps) # rubocop:disable RSpec/MessageSpies
      expect(validator).to receive(:check_schooling) # rubocop:disable RSpec/MessageSpies
      validator.validate
    end
  end
end
