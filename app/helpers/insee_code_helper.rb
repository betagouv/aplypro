# frozen_string_literal: true

module InseeCodeHelper
  def display_insee_code(code)
    return "Aucun code renseigné" if code.blank?

    InseeCountryCodeMapper.call(code)
  rescue InseeCountryCodeMapper::UnusableCountryCode
    "Code non utilisable"
  rescue InseeCountryCodeMapper::WrongCountryCodeFormat
    "Format de code incorrect"
  rescue InseeCountryCodeMapper::InseeCountryCodeError
    "Erreur lors du traitement du code"
  end
end
