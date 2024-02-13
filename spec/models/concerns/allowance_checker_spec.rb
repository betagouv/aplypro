# frozen_string_literal: true

require "rails_helper"

describe AllowanceChecker do
  subject(:student) { create(:student, :with_all_asp_info) }

  let(:wage) { create(:wage, yearly_cap: 100, daily_rate: 10) }
  let(:mef) { create(:mef, code: "123", wage: wage) }
  let(:classe) { create(:classe, mef: mef) }
  let(:schooling) { create(:schooling, student: student, classe: classe) }

  describe "allowance_left" do
    subject(:amount) { student.allowance_left(mef) }

    context "when the student has no PFMPs" do
      it { is_expected.to eq 100 }
    end

    context "when another student in the same class has a payment" do
      before do
        create(:pfmp, :with_pending_payment, classe: classe, day_count: 300)
      end

      it "does not account for it" do
        expect(amount).to eq 100
      end
    end

    context "when the student has a PFMP with that mef" do
      let(:pfmp) { create(:pfmp, schooling: schooling, day_count: 3) }

      context "without a payment" do
        it { is_expected.to eq 100 }
      end

      context "with a payment" do
        let!(:pfmp) { create(:pfmp, :paid, schooling: schooling, day_count: 3) }

        it { is_expected.to eq 70 }

        context "when it's from another year" do
          before { pfmp.schooling.update!(classe: create(:classe, start_year: 2024)) }

          it "does not account for it" do
            expect(amount).to eq 100
          end
        end

        context "when it is failed" do
          let(:pfmp) { create(:pfmp, :with_failed_payment, schooling: schooling, day_count: 3) }

          it "still accounts for it" do
            expect(amount).to eq 70
          end
        end

        context "when it is pending" do
          let(:pfmp) { create(:pfmp, :with_pending_payment, schooling: schooling, day_count: 3) }

          it { is_expected.to eq 70 }
        end
      end
    end

    context "when the student has multiple PFMPs" do
      before { create_list(:pfmp, 3, :paid, schooling: schooling, day_count: 3) }

      it { is_expected.to eq 10 }
    end

    context "when the student is in a new class with the same diploma" do
      before do
        create(:pfmp, :paid, schooling: schooling, day_count: 3)

        student.close_current_schooling!
        new_classe = create(:classe, mef: mef)
        new_schooling = create(:schooling, student: student, classe: new_classe)

        create(:pfmp, :paid, schooling: new_schooling, day_count: 2)
      end

      it { is_expected.to eq 50 }
    end
  end
end
