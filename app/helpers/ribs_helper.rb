# frozen_string_literal: true

module RibsHelper
  def rib_badge(student)
    success_badge(student.rib(current_establishment).present?, "Coordonnées bancaires")
  end

  def format_iban(iban)
    iban&.gsub(/(.{4})/, '\1 ')
  end

  def mask_iban(iban)
    start = iban[0, 4]
    ending = iban[-7, 7]
    middle = "*" * (iban.length - 11)

    format_iban("#{start}#{middle}#{ending}")
  end
end
