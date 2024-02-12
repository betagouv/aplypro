# frozen_string_literal: true

module ASP
  class Request < ApplicationRecord
    has_one_attached :file, service: :ovh_asp
    has_one_attached :rejects_file, service: :ovh_asp
    has_one_attached :integrations_file, service: :ovh_asp

    class << self
      def with_payments(payments, formatter)
        instance = create.tap do |obj|
          obj.attach_asp_file(formatter.new(payments))
        end

        instance.mark_payments!(payments)

        instance
      end
    end

    def send!(server)
      server.drop_file!(
        io: file.download,
        path: file.blob.filename.to_s
      )

      update!(sent_at: DateTime.now)
    end

    def mark_payments!(payments)
      ids = payments.pluck(:id)

      Payment.where(id: ids).update(asp_request_id: id)
    end

    def attach_asp_file(file)
      self.file.attach(
        io: StringIO.new(file.to_xml),
        content_type: "text/xml",
        filename: file.filename
      )
    end
  end
end