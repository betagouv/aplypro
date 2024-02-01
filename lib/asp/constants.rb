# frozen_string_literal: true

module ASP
  module Constants
    XMLNS = "http://www.cnasea.fr/fichier"

    CODE_DISPOSITIF  = ENV.fetch("APLYPRO_ASP_PROGRAM_CODE")
    CODE_SITE_OP     = ENV.fetch("APLYPRO_ASP_SITE_OPERATOR")
    CODE_UTILISATEUR = ENV.fetch("APLYPRO_ASP_USER_CODE")
  end
end
