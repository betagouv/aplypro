# frozen_string_literal: true

require "rails_helper"

describe StudentsApi::Sygne::Mappers::ClasseMapper do
  subject(:mapper) { described_class.new }

  describe "when there is no national MEF code" do
    let(:entry) { build(:sygne_student, mef: nil) }

    it "ignores the entry" do
      expect { mapper.call(entry) }.not_to raise_error
    end
  end
end
