# frozen_string_literal: true

require "rails_helper"

describe ASP::Entities::PersonnePhysique do
  let(:student) { create(:student, :female, :with_address_info, :with_birthplace_info, first_name: "Marie") }

  it_behaves_like "an ASP student mapping entity"

  it_behaves_like "an XML-fragment producer" do
    let(:entity) { described_class.from_student(student) }
    let(:probe) { ["persphysique/prenom", "Marie"] }
  end
end
