# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateAttributiveDecisionsJob do
  let(:etab) { create(:establishment, :with_fim_user) }

  before { create_list(:classe, 2, :with_students, students_count: 3, establishment: etab) }

  it "generates one attributive decision per student" do
    expect { described_class.perform_now(etab) }.to change(
      Schooling.joins(:attributive_decision_attachment),
      :count
    ).by(6)
  end

  it "generates an archive with all attributives decisions" do
    expect { described_class.perform_now(etab) }.to change { etab.attributive_decisions_zip.attached? }.to true
  end
end
