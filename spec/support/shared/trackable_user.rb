# frozen_string_literal: true

RSpec.shared_examples "a trackable user" do |factory_name|
  describe "trackable functionality" do
    describe "trackable fields" do
      it { is_expected.to respond_to(:sign_in_count) }
      it { is_expected.to respond_to(:current_sign_in_at) }
      it { is_expected.to respond_to(:last_sign_in_at) }
      it { is_expected.to respond_to(:current_sign_in_ip) }
      it { is_expected.to respond_to(:last_sign_in_ip) }
    end

    describe "sign in tracking" do
      let(:user) { create(factory_name) }

      it "initializes sign_in_count to 0" do
        expect(user.sign_in_count).to eq(0)
      end

      it "updates trackable fields when user signs in" do
        old_sign_in_time = 1.hour.ago
        user.update!(current_sign_in_at: old_sign_in_time, sign_in_count: 1)

        user.update_tracked_fields!(request_double)

        expect(user.sign_in_count).to eq(2)
        expect(user.last_sign_in_at).to be_within(1.second).of(old_sign_in_time)
        expect(user.current_sign_in_at).to be_within(1.second).of(Time.current)
      end

      private

      def request_double
        instance_double(ActionDispatch::Request, remote_ip: "192.168.1.1")
      end
    end
  end
end
