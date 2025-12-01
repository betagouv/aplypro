# frozen_string_literal: true

OmniAuth.config.test_mode = true
OmniAuth.config.request_validation_phase = nil

After do
  OmniAuth.config.mock_auth[:fim] = nil
  OmniAuth.config.mock_auth[:masa] = nil
  OmniAuth.config.mock_auth[:asp] = nil
end
