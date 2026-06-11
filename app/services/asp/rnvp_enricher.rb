# frozen_string_literal: true

module ASP
  class RnvpEnricher
    BATCH_THRESHOLD = 10
    CACHE_KEY_PREFIX = "rnvp_data"
    CACHE_EXPIRY = 1.week

    def self.enrich_recovery_students!(payment_requests)
      students = payment_requests.map(&:student).uniq
      new(students).enrich! if students.any?
    end

    def initialize(students)
      @students = students.uniq
    end

    def enrich!
      data = fetch_data
      @students.each do |student|
        raise ASP::Errors::MissingRnvpDataError, "No RNVP data for student #{student.id}" unless data[student.id]

        Rails.cache.write([CACHE_KEY_PREFIX, student.id], data[student.id], expires_in: CACHE_EXPIRY)
      end
    end

    private

    def fetch_data
      rnvp = Omogen::Rnvp.new
      if @students.count > BATCH_THRESHOLD
        rnvp.addresses(@students).index_by { |address| address["id"].to_i }
      else
        @students.to_h { |s| [s.id, rnvp.address(s)] }
      end
    end
  end
end
