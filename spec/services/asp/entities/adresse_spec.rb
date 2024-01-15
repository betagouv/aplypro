# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Adresse, type: :model do
  describe ".from_student" do
    subject(:model) { described_class.from_student(student) }

    let(:student) { create(:student, :with_french_address) }

    describe "validation" do
      context "when the address is in France" do
        it { is_expected.to validate_presence_of(:codepostalcedex) }
        it { is_expected.to validate_presence_of(:codecominsee) }
      end

      context "when the address is abroad" do
        let(:student) { create(:student, :with_foreign_address) }

        it { is_expected.to validate_presence_of(:localiteetranger) }
        it { is_expected.to validate_presence_of(:bureaudistribetranger) }
      end
    end

    it_behaves_like "an XML-fragment producer" do
      let(:entity) { described_class.from_student(student) }
      let(:probe) { ["adresse/codecominsee", student.address_city_insee_code] }
    end
  end
end
