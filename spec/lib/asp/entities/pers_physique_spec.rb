# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::PersPhysique, type: :model do
  let(:payment_request) { create(:asp_payment_request, :ready) }
  let(:student) { create(:student, :with_all_asp_info, first_name: "Marie") }

  before do
    payment_request.payment.schooling.update!(student: student)

    payment_request.reload
  end

  describe "validation" do
    subject(:model) { described_class.from_payment_request(payment_request) }

    context "when the student is born in France" do
      let(:student) { create(:student, :with_extra_info, :born_in_france) }

      it { is_expected.to validate_presence_of(:codeinseecommune) }
    end

    context "when the student was born abroad" do
      let(:student) { create(:student, :with_extra_info, :born_abroad) }

      it { is_expected.not_to validate_presence_of(:codeinseecommune) }
    end
  end

  it_behaves_like "an ASP payment mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_payment_request(payment_request) }
    let(:probe) { ["persphysique/prenom", "Marie"] }
  end
end
