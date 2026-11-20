# frozen_string_literal: true

module ASP
  class AttachDocument
    DESCRIPTIONS = {
      attributive_decision: "décision-d-attribution",
      abrogation_decision: "décision-d-abrogation",
      cancellation_decision: "décision-de-retrait",
      liquidation: "état-liquidatif"
    }.freeze

    class << self
      def from_schooling(output, schooling, attachment_name)
        raise "Unsupported attachment type" unless DESCRIPTIONS.keys.include?(attachment_name)

        attachment = schooling.public_send(attachment_name)

        name = attachment_file_name(schooling, DESCRIPTIONS[attachment_name])

        blob = ActiveStorage::Blob.create_and_upload!(
          io: output,
          filename: name,
          content_type: "application/pdf",
          metadata: { archive_path: archive_path(schooling.classe, name) }
        )

        attachment.attach(blob)
      end

      def attachment_file_name(schooling, description)
        [
          schooling.student.last_name,
          schooling.student.first_name,
          description,
          schooling.attributive_decision_number
        ].join("_").concat(".pdf")
      end

      def archive_path(classe, filename)
        [
          classe.establishment.uai,
          classe.school_year.start_year,
          classe.label.parameterize,
          filename
        ].join("/")
      end
    end
  end
end
