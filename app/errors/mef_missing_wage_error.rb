# frozen_string_literal: true

class MefMissingWageError < StandardError
  attr_reader :mef_code

  def initialize(mef_code)
    @mef_code = mef_code
    super("MEF #{mef_code} has no associated wage")
  end
end
