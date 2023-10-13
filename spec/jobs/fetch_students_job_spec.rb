# frozen_string_literal: true

require "rails_helper"

RSpec.describe FetchStudentsJob do
  let(:etab) { create(:establishment, :with_fim_user) }

  before do
    allow(StudentApi).to receive(:fetch_students!)
  end

  it "calls the matchingStudentApi proxy" do
    described_class.perform_now(etab)

    expect(StudentApi).to have_received(:fetch_students!).with(etab)
  end
end
