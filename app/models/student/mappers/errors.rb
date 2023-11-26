# frozen_string_literal: true

class Student
  module Mappers
    module Errors
      class Error < ::StandardError; end
      class StudentParsingError < Error; end
      class SchoolingParsingError < Error; end
      class ClasseParsingError < Error; end
    end
  end
end
