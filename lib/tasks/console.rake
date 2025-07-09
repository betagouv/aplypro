# frozen_string_literal: true

namespace :console do
  desc "Start Rails console with support overrides"
  task support: :environment do
    load "support/overrides.rb"
    require "irb"
    IRB.start
  end
end
