# frozen_string_literal: true

module RibsHelper
  def rib_badge(student)
    success_badge(student.rib.present?, "Coordonnées bancaires")
  end

  def hide_iban(iban)
    return "" if iban.blank?
    iban[0,4] + "*" * (iban.length - 7) + iban[-3,3]
  end
end
