# frozen_string_literal: true

module ASP
  class Request < ApplicationRecord
    MAX_FILES_PER_DAY = 10
    MAX_RECORDS_PER_FILE = 7000
    MAX_RECORDS_PER_WEEK = 100_000

    has_one_attached :file, service: :ovh_asp
    has_one_attached :rejects_file, service: :ovh_asp
    has_one_attached :integrations_file, service: :ovh_asp
    has_one_attached :correction_adresse_file, service: :ovh_asp

    has_many :asp_payment_requests,
             class_name: "ASP::PaymentRequest",
             dependent: :nullify,
             inverse_of: :asp_request

    validates :asp_payment_requests, length: { maximum: MAX_RECORDS_PER_FILE }

    scope :sent_at, ->(range) { where(sent_at: range) }
    scope :sent_today, -> { sent_at(Time.current.all_day) }
    scope :sent_this_week, -> { sent_at(Time.current.all_week) } # thank you Active Support <3

    validate :all_requests_ready?, on: :create, unless: :correction_adresse

    validates :asp_payment_requests, presence: true, unless: :correction_adresse

    attr_reader :asp_file
    attr_accessor :correction_adresse

    class << self
      def total_payment_requests_sent_today
        sent_today.sum { |request| request.asp_payment_requests.count }
      end

      def total_payment_requests_sent_this_week
        sent_this_week.sum { |request| request.asp_payment_requests.count }
      end

      def total_files_sent_today
        sent_today.count
      end

      def total_payment_requests_left
        MAX_RECORDS_PER_WEEK - total_payment_requests_sent_this_week
      end

      def daily_requests_limit_reached?
        total_files_sent_today >= MAX_FILES_PER_DAY
      end
    end

    def send!(rerun: false)
      raise ASP::Errors::RerunningParsedRequest if results_attached?

      ActiveRecord::Base.transaction do
        @asp_file = ASP::Entities::Fichier.new(asp_payment_requests)

        @asp_file.validate!

        attach_asp_file!
        upload_file!
        update_sent_timestamp!
        update_requests! unless rerun
      end
    end

    def send_correction_adresse!(payment_requests)
      ActiveRecord::Base.transaction do
        @asp_file = ASP::Entities::CorrectionAdresseFichier.new(payment_requests)
        @asp_file.validate!
        correction_adresse_file.attach(io: StringIO.new(@asp_file.to_xml),
                                       content_type: "text/xml", filename: @asp_file.filename)
        ASP::Server.upload_file!(io: @asp_file.to_xml, path: @asp_file.filename)
        update!(sent_at: DateTime.now)
      end
    end

    def upload_file!
      ASP::Server.upload_file!(
        io: @asp_file.to_xml,
        path: @asp_file.filename
      )
    end

    def update_sent_timestamp!
      update!(sent_at: DateTime.now)
    end

    def update_requests!
      asp_payment_requests.each(&:mark_sent!)
    end

    def attach_asp_file!
      file.attach(io: StringIO.new(@asp_file.to_xml), content_type: "text/xml", filename: @asp_file.filename)
    end

    def sent_ids
      @sent_ids ||= Nokogiri::XML(file.download)
                            .search("ENREGISTREMENT")
                            .pluck("idEnregistrement")
    end

    def parse_response_file!(type)
      reader_for(type).process!
    end

    def attachment_for(type)
      public_send "#{type}_file"
    end

    private

    def reader_for(type)
      klass = "ASP::Readers::#{type.capitalize}FileReader".constantize

      klass.new(io: attachment_for(type).download)
    end

    def results_attached?
      integrations_file.attached? || rejects_file.attached?
    end

    # NOTE: this validation is tricky because the request might not be
    # persisted yet, which means it has no ID, which means asking for
    # `asp_payment_requests` on its own might trigger the actual query
    # with a NULL asp_payment_requests.request_id (as `.to_sql` will
    # demonstrate). I'm not sure what's the best way to avoid the SQL
    # path so just map the ID here which uses the value of the actual
    # variable in the function.
    def all_requests_ready?
      return false if asp_payment_requests.none?

      total = ASP::PaymentRequest
              .in_state(:ready)
              .where(id: asp_payment_requests.map(&:id))
              .length

      errors.add(:base, :requests_in_wrong_state) unless total == asp_payment_requests.length
    end
  end
end
