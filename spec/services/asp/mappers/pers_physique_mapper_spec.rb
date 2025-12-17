# frozen_string_literal: true

require "rails_helper"

describe ASP::Mappers::PersPhysiqueMapper do
  subject(:mapper) { described_class.new(payment_request) }

  let(:payment_request) { create(:asp_payment_request) }
  let(:student) { payment_request.student }

  described_class::MAPPING.each do |name, mapping|
    it "maps to the student's`#{mapping}'" do
      if mapping.eql?(:first_names)
        expect(mapper.send(name)).to eq "#{student.first_name}, #{student.first_name2}, #{student.first_name3}"
      else
        expect(mapper.send(name)).to eq student[mapping]
      end
    end
  end

  describe "codeinseepaysnai" do
    subject(:code) { mapper.codeinseepaysnai }

    before do
      allow(InseeCountryCodeMapper).to receive(:call).and_return :value
    end

    it "delegates to the INSEE country code mapper" do
      expect(code).to eq :value
    end
  end

  describe "codeinseecommune" do
    context "when the birthplace city insee code has no exception" do
      before { student.update!(birthplace_city_insee_code: "12345") }

      it { expect(mapper.codeinseecommune).to eq "12345" }
    end

    context "when the birthplace city insee code has an exception and before 2008-01-01" do
      before { student.update!(birthplace_city_insee_code: "97801", birthdate: "2005-05-05") }

      it { expect(mapper.codeinseecommune).to eq "97127" }
    end

    context "when the birthplace city insee code has an exception and after 2007-12-31" do
      before { student.update!(birthplace_city_insee_code: "97127", birthdate: "2015-05-05") }

      it { expect(mapper.codeinseecommune).to eq "97801" }
    end
  end
end
