require 'rails_helper'

RSpec.describe Principal, type: :model do
  it "has a valid factory" do
    expect(FactoryBot.build(:principal)).to be_valid
  end

  # describe 'associations' do
  #   it { should belong_to(:category).class_name('MenuCategory') }
  # end

  describe "validations" do
    %w[uid name email provider token secret email].each do |attr|
      it { is_expected.to validate_presence_of(attr) }
    end
  end
end
