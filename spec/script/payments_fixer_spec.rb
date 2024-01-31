# frozen_string_literal: true

require "rails_helper"
require "./script/payments_fixer"

RSpec.describe PaymentsFixer do
  subject(:fix) { described_class.fix_all! }

  before do
    create_list(:pfmp, 10, :validated)
  end

  it "goes well" do
    expect { fix }.not_to raise_error
  end
end
