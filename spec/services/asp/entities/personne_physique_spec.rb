# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::PersonnePhysique, type: :model do
  let(:student) { create(:student, :female, :with_address_info, :with_birthplace_info, first_name: "Marie") }
  let(:payment) { create(:payment) }

  before { payment.pfmp.update!(student: student) }

  describe "validation" do
    subject(:model) { described_class.from_payment(payment) }

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
    let(:entity) { described_class.from_payment(payment) }
    let(:probe) { ["persphysique/prenom", "Marie"] }
  end
end
