# frozen_string_literal: true

module ASP
  module BopMapper
    class << self
      def to_unite_suivi(ministry:, private_establishment:)
        ENV.fetch(unite_suivi_key(ministry:, private_establishment:))
      end

      private

      def unite_suivi_key(ministry:, private_establishment: false)
        template = "APLYPRO_ASP_%s_US"

        key = case ministry
              when "menj"
                private_establishment ? "MENJ_PRIVATE" : "MENJ_PUBLIC"
              else
                ministry.to_s.upcase
              end

        template % key
      end
    end
  end
end
