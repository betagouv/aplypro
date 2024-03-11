require "administrate/field/base"

class DaLinkField < Administrate::Field::Base
  def to_s
    student_id = resource.id
    schoolings = Schooling.where(student_id: student_id).with_attributive_decisions
    attributive_decision = schoolings.map(&:attributive_decision).compact
    attributive_decision.map do |ad|
      if ad.attached?
        file_path = Rails.application.routes.url_helpers.rails_blob_path(ad, only_path: true)
        "<a href='#{file_path}'>#{data} #{ad.filename.to_s}</a>"
      end
    end.join(", ").html_safe
  end
end
