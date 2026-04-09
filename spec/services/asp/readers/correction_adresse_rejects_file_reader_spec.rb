# frozen_string_literal: true

require "rails_helper"

require "./mock/factories/asp"

describe ASP::Readers::CorrectionAdresseRejectsFileReader do
  subject(:reader) { described_class.new(io: data) }

  let(:asp_payment_request) { create(:asp_payment_request, :sent) }
  let(:data) { build(:asp_reject, payment_request: asp_payment_request) }

  it "raises CorrectionAdresseRejectedError" do
    expect { reader.process! }.to raise_error(ASP::Errors::CorrectionAdresseRejectedError)
  end

  it "includes the payment request id in the error message" do
    expect { reader.process! }
      .to raise_error(ASP::Errors::CorrectionAdresseRejectedError, /#{asp_payment_request.id}/)
  end
end
