# frozen_string_literal: true

Before do
  @env = ENV.to_hash
end

After do
  ENV.replace(@env)
end
