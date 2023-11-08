# frozen_string_literal: true

require "rails_helper"

RSpec.describe IdentityMappers::Fim do
  subject(:mapper) { described_class.new(attributes) }

  let(:fredurneresp) { [build(:fredurneresp, uai: "456")] }
  let(:attributes) { { "FrEduRneResp" => fredurneresp, "FrEduFonctAdm" => "DIR" } }

  describe "#responsibilities" do
    subject(:result) { mapper.responsibility_uais }

    context "when the AplyproResp attribute is present" do
      before do
        attributes.merge!({ "AplyproResp" => "123" })
      end

      it { is_expected.to contain_exactly "456", "123" }
    end
  end
end
