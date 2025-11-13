# frozen_string_literal: true

class ReportNotFoundError < StandardError
  attr_reader :school_year

  def initialize(school_year)
    @school_year = school_year
    super("No report available for school year #{school_year}")
  end
end
