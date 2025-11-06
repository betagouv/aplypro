# frozen_string_literal: true

module RibsHelper
  def rib_badge(student)
    success_badge(student.rib(current_establishment).present?, "Coordonnées bancaires")
  end

  def format_iban(iban)
    iban&.gsub(/(.{4})/, '\1 ')
  end
end
