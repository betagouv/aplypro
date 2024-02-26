# frozen_string_literal: true

class InseeCountryCodeMapper
  REJECTED_CODES = {
    "995" => :no_nationality,
    "990" => :other_countries
  }.freeze

  class InseeCountryCodeError < ::StandardError; end
  class UnusableCountryCode < InseeCountryCodeError; end
  class WrongCountryCodeFormat < InseeCountryCodeError; end

  def self.call(*)
    new(*).call
  end

  attr_reader :code

  def initialize(code)
    @code = code
  end

  def call
    case code.length
    when 5
      code
    when 3
      handle_sygne_country_code
    else
      raise WrongCountryCodeFormat
    end
  end

  private

  def handle_sygne_country_code
    raise UnusableCountryCode if REJECTED_CODES.keys.include?(code)

    code.rjust(5, "99")
  end
end
