# frozen_string_literal: true

RSpec.describe IdentityMappers::Fim do
  subject(:mapper) { described_class.new(attributes) }

  let(:attributes) { {} }

  describe "#responsibilities" do
    subject(:result) { mapper.responsibilities }

    context "when the AplyproResp attribute is present" do
      let(:attributes) { { "AplyproResp" => "123" } }

      it { is_expected.to include a_hash_including(uai: "123") }
    end
  end
end
