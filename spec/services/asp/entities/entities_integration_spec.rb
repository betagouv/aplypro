# frozen_string_literal: true

require "rails_helper"

# NOTE: this spec doesn't describe an actual class but ties all of the
# ASP XML entities together by validating against the XSD schema,
# which cannot be done at the individual entity level (i.e you cannot
# validate an <ADRESSE></ADRESSE> subset with the schema).
#
# It grabs the root class (Fichier), instantiates it with a complete
# data model and checks whether the resulting XML is valid. This was
# initially part of the fichier_spec.rb but re-running all of the
# other specs in it felt wrong, and probably indicates this code will
# live somewhere else in the future.
describe "ASP Entities" do # rubocop:disable RSpec/DescribeClass
  subject(:file) { ASP::Entities::Fichier.new(payments) }

  let(:payments) do
    student = create(:student, :with_extra_info, :with_rib, :with_french_address)
    pfmp = create(:pfmp, student: student)
    payment = create(:payment, pfmp: pfmp)

    [payment]
  end

  it "produce valid documents" do
    expect { file.validate! }.not_to raise_error
  end
end
