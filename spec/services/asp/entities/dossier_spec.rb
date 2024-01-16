# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::Dossier, type: :model do
  let(:schooling) { create(:schooling) }
  let(:student) { schooling.student }

  it_behaves_like "an ASP student mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_student(student) }
    let(:probe) { ["dossier/numadm", schooling.attributive_decision_number] }
  end
end
