# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::PrestadossMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request, :ready) }
  let(:schooling) { payment_request.schooling }

  describe "#numadm" do
    it "returns the schooling's administrative number with an index" do
      expect(mapper.numadm).to eq "#{schooling.attributive_decision_number}01"
    end

    context "when there are more than one PFMPs for that schooling" do
      before do
        create_list(:pfmp, 2, schooling: schooling, created_at: 3.days.ago)
      end

      it "accounts for the PFMP's index" do
        expect(mapper.numadm).to eq "#{schooling.attributive_decision_number}01"
      end
    end
  end
end
