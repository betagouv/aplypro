# frozen_string_literal: true

require "csv"
require_relative "mef_seeder"
require_relative "wage_seeder"

MefSeeder.seed
WageSeeder.seed
