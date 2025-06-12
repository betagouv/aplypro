# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::PersPhysique, type: :model do
  let(:schooling) { create(:schooling) }
  let(:student) { create(:student, :with_all_asp_info, first_name: "Marie") }

  before do
    schooling.update!(student: student)

    schooling.reload
  end

  describe "validation" do
    subject(:model) { described_class.from_schooling(schooling) }

    include_examples "a limited string attribute", attribute: :prenom, length: 20
    include_examples "a limited string attribute", attribute: :nomnaissance, length: 50
    include_examples "a limited string attribute", attribute: :nomusage, length: 50
    include_examples "an ASP-friendly date attribute", attribute: :datenaissance

    context "when the student is born in France" do
      let(:student) { create(:student, :with_extra_info, :born_in_france) }

      it { is_expected.to validate_presence_of(:codeinseecommune) }
    end

    context "when the student was born abroad" do
      let(:student) { create(:student, :with_extra_info, :born_abroad) }

      it { is_expected.not_to validate_presence_of(:codeinseecommune) }
    end
  end

  it_behaves_like "a schooling mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_schooling(schooling) }
    let(:probe) { ["persphysique/prenom", "Marie"] }

    context "when the student is born abroad" do
      let(:student) { create(:student, :with_all_asp_info, :born_abroad) }

      it "does not include the <codeinseecommune> tag" do
        expect(document.at("persphysique/codeinseecommune")).to be_nil
      end
    end
  end
end
