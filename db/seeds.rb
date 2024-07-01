# frozen_string_literal: true

require_relative "school_year_seeder"
require_relative "mef_seeder"
require_relative "wage_seeder"
require_relative "exclusion_seeder"

SchoolYearSeeder.seed
MefSeeder.seed
WageSeeder.seed
ExclusionSeeder.seed
