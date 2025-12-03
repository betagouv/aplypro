# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidationsFacade do
  subject(:validations_facade) { described_class.new(establishment, school_year) }

  let(:establishment) { create(:establishment) }
  let(:school_year) { SchoolYear.current }
  let(:classe) { create(:classe, establishment: establishment, school_year: school_year) }

  describe "#failed_pfmps_per_payment_request_state" do
    subject(:failed_pfmps) { validations_facade.failed_pfmps_per_payment_request_state }

    context "when there are no failed payment requests" do
      let!(:pfmp) { create(:pfmp, :validated, schooling: create(:schooling, classe: classe)) }

      before { create(:asp_payment_request, :paid, pfmp: pfmp) }

      it "returns empty hash" do
        expect(failed_pfmps).to be_empty
      end
    end

    # rubocop:disable RSpec/MultipleMemoizedHelpers
    context "when there are failed payment requests in different states" do
      let(:schooling_with_rejected) { create(:schooling, classe: classe) }
      let(:schooling_with_unpaid) { create(:schooling, classe: classe) }
      let(:schooling_with_incomplete) { create(:schooling, classe: classe) }

      let!(:pfmp_rejected) { create(:pfmp, :validated, schooling: schooling_with_rejected) }
      let!(:pfmp_unpaid) { create(:pfmp, :validated, schooling: schooling_with_unpaid) }
      let!(:pfmp_incomplete) { create(:pfmp, :validated, schooling: schooling_with_incomplete) }

      before do
        create(:asp_payment_request, :rejected, pfmp: pfmp_rejected)
        create(:asp_payment_request, :unpaid, pfmp: pfmp_unpaid)
        create(:asp_payment_request, :incomplete, pfmp: pfmp_incomplete)
      end

      it "groups pfmps by their latest payment request state" do
        expect(failed_pfmps.keys.map(&:to_sym)).to match_array(%i[rejected unpaid incomplete])
        expect(failed_pfmps["rejected"]).to include(pfmp_rejected)
        expect(failed_pfmps["unpaid"]).to include(pfmp_unpaid)
        expect(failed_pfmps["incomplete"]).to include(pfmp_incomplete)
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers

    context "when a pfmp has multiple payment requests" do
      let(:schooling) { create(:schooling, classe: classe) }
      let!(:pfmp) { create(:pfmp, :validated, schooling: schooling) }

      before do
        pr1 = create(:asp_payment_request, :rejected, pfmp: pfmp)
        # rubocop:disable Rails/SkipsModelValidations
        pr1.update_columns(created_at: 2.days.ago)
        pr1.asp_payment_request_transitions.update_all(created_at: 2.days.ago)
        # rubocop:enable Rails/SkipsModelValidations
        create(:asp_payment_request, :incomplete, pfmp: pfmp)
      end

      it "only considers the latest payment request by created_at" do
        expect(pfmp.payment_requests.count).to be >= 2
        latest_state = pfmp.payment_requests.order(created_at: :desc).first.current_state
        expect(latest_state).to eq("incomplete")
        expect(failed_pfmps["incomplete"]).to include(pfmp)
      end
    end

    context "when there are pfmps from another school year" do
      let!(:pfmp_current_year) do
        create(:pfmp, :validated, schooling: create(:schooling, classe: classe))
      end

      let!(:pfmp_other_year) do
        other_school_year = SchoolYear.find_or_create_by!(start_year: SchoolYear.current.start_year - 1)
        other_classe = create(:classe, establishment: establishment, school_year: other_school_year)
        other_schooling = create(:schooling, classe: other_classe)

        create(:pfmp, :validated,
               schooling: other_schooling,
               start_date: "#{other_school_year.start_year}-09-03",
               end_date: "#{other_school_year.start_year}-09-18")
      end

      before do
        create(:asp_payment_request, :rejected, pfmp: pfmp_current_year)
        create(:asp_payment_request, :rejected, pfmp: pfmp_other_year)
      end

      it "only includes pfmps from the selected school year" do
        expect(failed_pfmps["rejected"]).to include(pfmp_current_year)
        expect(failed_pfmps["rejected"]).not_to include(pfmp_other_year)
      end
    end

    context "when there are pfmps from another establishment" do
      let!(:pfmp_current_establishment) do
        create(:pfmp, :validated, schooling: create(:schooling, classe: classe))
      end

      let!(:pfmp_other_establishment) do
        other_establishment = create(:establishment)
        other_classe = create(:classe, establishment: other_establishment, school_year: school_year)
        other_schooling = create(:schooling, classe: other_classe)

        create(:pfmp, :validated, schooling: other_schooling)
      end

      before do
        create(:asp_payment_request, :rejected, pfmp: pfmp_current_establishment)
        create(:asp_payment_request, :rejected, pfmp: pfmp_other_establishment)
      end

      it "only includes pfmps from the selected establishment" do
        expect(failed_pfmps["rejected"]).to include(pfmp_current_establishment)
        expect(failed_pfmps["rejected"]).not_to include(pfmp_other_establishment)
      end
    end

    context "when a pfmp transitions from failed to successful state" do
      let(:schooling) { create(:schooling, classe: classe) }
      let!(:pfmp) { create(:pfmp, :validated, schooling: schooling) }

      before do
        create(:asp_payment_request, :rejected, pfmp: pfmp, created_at: 2.days.ago)
        create(:asp_payment_request, :paid, pfmp: pfmp, created_at: 1.day.ago)
      end

      it "does not include the pfmp in failed results" do
        expect(failed_pfmps).to be_empty
      end
    end
  end

  describe "#validatable_classes" do
    subject(:validatable_classes) { validations_facade.validatable_classes }

    it "delegates to establishment.validatable_pfmps for the school year" do
      mock_pluck = instance_double(ActiveRecord::Relation, pluck: [classe.id])
      mock_pfmps = instance_double(ActiveRecord::Relation, distinct: mock_pluck)
      allow(establishment).to receive(:validatable_pfmps).and_return(mock_pfmps)

      expect(validatable_classes).to include(classe)
    end
  end
end
