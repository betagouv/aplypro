# frozen_string_literal: true

require_relative "mef_seeder"
require_relative "wage_seeder"
require_relative "exclusion_seeder"

MefSeeder.seed
WageSeeder.seed
ExclusionSeeder.seed
