# frozen_string_literal: true

module Academic
  module StudentsHelper
    def schoolings_with_pfmps(schoolings)
      schoolings.select { |s| s.pfmps.any? }
    end

    def pfmps?(schoolings)
      schoolings_with_pfmps(schoolings).any?
    end
  end
end
