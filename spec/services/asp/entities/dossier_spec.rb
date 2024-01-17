# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Dossier, type: :model do
  let(:payment) { create(:payment) }
  let(:schooling) { payment.pfmp.schooling }

  it_behaves_like "an ASP payment mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment(payment) }
    let(:probe) { ["dossier/numadm", schooling.attributive_decision_number] }
  end
end
