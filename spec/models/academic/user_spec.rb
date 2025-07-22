# frozen_string_literal: true

require "rails_helper"

RSpec.describe Academic::User do
  describe "validations" do
    %w[uid name email provider].each do |attr|
      it { is_expected.to validate_presence_of(attr) }
    end
  end

  it_behaves_like "a trackable user", :academic_user
end
