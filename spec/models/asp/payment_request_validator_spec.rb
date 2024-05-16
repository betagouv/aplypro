# frozen_string_literal: true

require "rails_helper"

describe ASP::PaymentRequestValidator do
  subject(:validator) { described_class.new(asp_payment_request) }

  let(:asp_payment_request) { create(:asp_payment_request, :ready) }

  RSpec.shared_examples "invalidation" do |attr|
    it "adds a `#{attr}` error" do
      expect { validator.validate }
        .to change { asp_payment_request.errors.details[:ready_state_validation] }
        .to include(a_hash_including(error: attr))
    end
  end

  context "when the schooling status is unknown" do
    before { asp_payment_request.schooling.update!(status: nil) }

    include_examples "invalidation", :student_type
  end

  context "when the schooling is for an apprentice" do
    before { asp_payment_request.schooling.update!(status: :apprentice) }

    include_examples "invalidation", :student_type
  end

  context "when the student is a lost record" do
    before { asp_payment_request.student.update!(ine_not_found: true) }

    include_examples "invalidation", :ine_not_found
  end

  # rubocop:disable Rails/SkipsModelValidations
  context "when the PFMP is not valid" do
    before { asp_payment_request.pfmp.update_column(:start_date, Date.new(2002, 1, 1)) }

    include_examples "invalidation", :pfmp
  end

  context "when the rib is not valid" do
    before do
      with_readonly_bypass(asp_payment_request.student.rib) do |rib|
        rib.update_columns(attributes_for(:rib, :outside_sepa))
      end
    end

    include_examples "invalidation", :rib
  end
  # rubocop:enable Rails/SkipsModelValidations

  context "when the PFMP is zero-amount" do
    before { asp_payment_request.pfmp.update!(amount: 0) }

    include_examples "invalidation", :pfmp_amount
  end

  context "when the RIB is missing" do
    before do
      with_readonly_bypass(asp_payment_request.student.rib) do |rib|
        rib.destroy

        rib.student.reload
      end
    end

    include_examples "invalidation", :missing_rib
  end

  context "when the request belongs to a student over 18 with an external rib" do
    before do
      asp_payment_request.student.update!(birthdate: 20.years.ago)

      with_readonly_bypass(asp_payment_request.student.rib) { |rib| rib.update!(owner_type: :other_person) }
    end

    include_examples "invalidation", :adult_without_personal_rib
  end

  context "when the RIB belongs to a moral person" do
    before do
      with_readonly_bypass(asp_payment_request.student.rib) do |rib|
        # this makes sure we don't get caught by adult_without_personal_rib
        rib.student.update!(birthdate: 15.years.ago)

        rib.update!(owner_type: :moral_person)
      end
    end

    include_examples "invalidation", :rib_owner_moral
  end

  context "when the attributive decision has not been attached" do
    before do
      asp_payment_request.pfmp.schooling.attributive_decision.purge
                         .tap { asp_payment_request.reload }
    end

    include_examples "invalidation", :missing_attributive_decision
  end

  context "when there is another duplicated PFMP" do
    let(:duplicate) do
      pfmp = asp_payment_request.pfmp

      create(
        :pfmp,
        schooling: pfmp.schooling,
        start_date: pfmp.start_date,
        end_date: pfmp.end_date,
        day_count: pfmp.day_count
      )
    end

    context "when it is validated" do
      before { duplicate.validate! }

      include_examples "invalidation", :duplicates
    end

    context "when it's not validated" do
      it "doesn't add an error" do
        expect { validator.validate }.not_to change(asp_payment_request, :errors)
      end
    end
  end

  context "when the student lives abroad" do
    before { asp_payment_request.student.update!(address_country_code: "990") }

    include_examples "invalidation", :doesnt_live_in_france
  end

  context "when the schooling is excluded" do
    before { create(:exclusion, :whole_establishment, uai: asp_payment_request.schooling.establishment.uai) }

    include_examples "invalidation", :excluded_schooling
  end

  context "when the student needs abrogated attributive decisions" do
    before do
      schooling = create(:schooling, :closed, student: asp_payment_request.student)

      create(:pfmp, schooling: schooling)
    end

    include_examples "invalidation", :needs_abrogated_attributive_decision
  end

  context "when the student is missing biological sex" do
    before { asp_payment_request.student.update!(biological_sex: 0) }

    include_examples "invalidation", :missing_biological_sex
  end

  context "when the student is missing birthplace city INSEE code and is born in France" do
    before do
      asp_payment_request.student.update!(
        birthplace_country_insee_code: "99100",
        birthplace_city_insee_code: nil
      )
    end

    include_examples "invalidation", :missing_birthplace_city_insee_code
  end

  context "when the student is missing birthplace country INSEE code" do
    before do
      asp_payment_request.student.update!(
        birthplace_country_insee_code: nil
      )
    end

    include_examples "invalidation", :missing_birthplace_country_insee_code
  end

  context "when the student is missing address postal code" do
    before { asp_payment_request.student.update!(address_postal_code: nil) }

    include_examples "invalidation", :missing_address_postal_code
  end

  context "when the student is missing address city INSEE code" do
    before { asp_payment_request.student.update!(address_city_insee_code: nil) }

    include_examples "invalidation", :missing_address_city_insee_code
  end

  context "when the student is missing address country code" do
    before { asp_payment_request.student.update!(address_country_code: nil) }

    include_examples "invalidation", :missing_address_country_code
  end
end
