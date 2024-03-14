# frozen_string_literal: true

module ASP
  class PaymentReturn < ApplicationRecord
    has_one_attached :file

    validates :filename, presence: true, uniqueness: true

    def self.create_with_file!(io:, filename:)
      create!(filename: filename)
        .file.attach(
          io: StringIO.new(io),
          filename: filename,
          content_type: "text/xml"
        )
    end
  end
end
