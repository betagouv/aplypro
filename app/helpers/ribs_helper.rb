# frozen_string_literal: true

module RibsHelper
  def rib_badge(student)
    success_badge(student.rib.present?, "Coordonnées bancaires")
  end
end
