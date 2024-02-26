# frozen_string_literal: true

describe InseeCountryCodeMapper do
  subject(:result) { described_class.call(code) }

  context "when then country code is already 5 characters long" do
    # this is voluntarily wrong to explicit the fact we don't do any
    # actual processing of the code's content
    let(:code) { "ABCDE" }

    it "returns it" do
      expect(result).to eq "ABCDE"
    end
  end

  context "when the country code is 3 characters long" do
    let(:code) { "100" }

    it "pads it with 99" do
      expect(result).to eq "99100"
    end

    described_class::REJECTED_CODES.to_a.each do |code, reason|
      context "with a country code that indicates #{reason}" do
        let(:code) { code }

        it "raises an error" do
          expect { result }.to raise_error described_class::UnusableCountryCode
        end
      end
    end
  end

  context "when the country code is not 3 or 5 characters" do
    %w[1 12 1234 123456].each do |code|
      let(:code) { code }

      it "raises an error" do
        expect { result }.to raise_error described_class::WrongCountryCodeFormat
      end
    end
  end
end
