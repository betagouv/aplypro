# frozen_string_literal: true

module RibsHelper
  def rib_badge(student)
    status = student.rib.present? ? :success : :error
    success_badge(status, "Coordonnées bancaires")
  end
end
