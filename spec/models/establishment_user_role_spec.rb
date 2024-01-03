# frozen_string_literal: true

require "rails_helper"

RSpec.describe EstablishmentUserRole do
  subject(:establishment_user_role) { build(:establishment_user_role, :director) }

  describe "associations" do
    it { is_expected.to belong_to(:establishment).class_name("Establishment") }
    it { is_expected.to belong_to(:user).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:role) }

    it {
      # Rubocop is unhappy because you can't use implicit subjects
      # outside of one-line blocks, but if this was to be a one-liner then
      # the line would be too long... tough times.
      is_expected.to( # rubocop:disable RSpec/ImplicitSubject
        validate_uniqueness_of(:user)
          .scoped_to(:establishment_id)
          .ignoring_case_sensitivity
      )
    }
  end

  describe "changing from :dir to :authorised" do
    subject(:establishment_user_role) { create(:establishment_user_role, :director) }

    before { establishment_user_role.establishment.update(confirmed_director: establishment_user_role.user) }

    it "updates the establishment's confirm_director" do
      expect do
        establishment_user_role.update(role: :authorised)
      end.to change { establishment_user_role.establishment.confirmed_director }.to nil
    end
  end
end
