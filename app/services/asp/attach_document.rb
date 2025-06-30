# frozen_string_literal: true

module ASP
  class AttachDocument
    class << self
      def from_schooling(output, schooling, attachment_name)
        descriptions = {
          attributive_decision: "décision-d-attribution",
          abrogation_decision: "décision-d-abrogation",
          cancellation_decision: "décision-de-retrait"
        }

        raise "Unsupported attachment type" unless descriptions.keys.include?(attachment_name)

        name = attachment_file_name(
          schooling.student,
          descriptions[attachment_name],
          schooling.attributive_decision_number
        )

        attachment = schooling.public_send(attachment_name)

        attach_document(output, schooling, attachment, name)
      end

      def from_pfmp(output, pfmp)
        name = attachment_file_name(
          pfmp.schooling.student,
          "état-liquidatif",
          pfmp.num_presta_doss
        )

        attach_document(output, pfmp.schooling, pfmp.liquidation, name)
      end

      def attachment_file_name(student, description, number)
        [
          student.last_name,
          student.first_name,
          description,
          number
        ].join("_").concat(".pdf")
      end

      def attributive_decision_key(classe, filename)
        [
          classe.establishment.uai,
          classe.school_year.start_year,
          classe.label.parameterize,
          filename
        ].join("/")
      end

      private

      def attach_document(output, schooling, attachment, name)
        attachment.purge if attachment.present?

        attachment.attach(
          io: output,
          key: attributive_decision_key(schooling.classe, name),
          filename: name,
          content_type: "application/pdf"
        )
      end
    end
  end
end
