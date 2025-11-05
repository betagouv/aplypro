# frozen_string_literal: true

module RibsHelper
  def rib_badge(student)
    success_badge(student.rib.present?, "Coordonnées bancaires")
  end

  def format_iban(iban)
    iban&.gsub(/(.{4})/, '\1 ')
  end

  def hide_format_iban(iban)
    return "" if iban.blank?

    raw = iban.delete(" ")

    visible_start = 4
    visible_end = 3
    masked_length = raw.length - visible_start - visible_end
    masked = raw[0, visible_start] + ("*" * masked_length) + raw[-visible_end, visible_end]

    format_iban(masked)
  end
end
