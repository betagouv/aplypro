# frozen_string_literal: true

require "csv"
require_relative "mef_seeder"
require_relative "wage_mefstat4_seeder"

MefSeeder.seed
WageMefstat4Seeder.seed
