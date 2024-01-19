# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Prestadoss, type: :model do
  let(:payment) { create(:payment) }
  let(:schooling) { payment.pfmp.schooling }

  it_behaves_like "an ASP payment mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment(payment) }
    let(:probe) { ["prestadoss/numadm", schooling.attributive_decision_number] }
  end
end