# frozen_string_literal: true

# rubocop:disable all
module Generator
  # Generate "Etat Liquidatif"
  class Liquidation < Document
    attr_reader :pfmp, :rib

    def initialize(schooling)
      @rib = schooling.student.rib(schooling.establishment.id)
      super
    end

    def render
      setup_styles
      header
      summary
      articles
    end

    def write
      io = StringIO.new

      schooling.pfmps.in_state(:validated, :rectified).each do |pfmp|
        @pfmp = pfmp
        @title = "Etat liquidatif"
        @state = "validated"

        if @pfmp.rectified?
          # Pour une PFMP rectifiée, il faut faire 2 pages :
          # - Etat liquidatif / Date de la validation / Montant de la métadata
          # - Etat liquidatif rectificatif / Date de la rectification / Montant de la PFMP
          @amount = @pfmp.paid_amount

          render

          @title += " rectificatif"
          @state = "rectified"
        end

        @amount = pfmp.amount

        render
        composer.new_page unless pfmp == schooling.pfmps.last
      end

      composer.write(io)
      io.rewind
      io
    end

    private

    def articles
      composer.text("Certifie avoir procédé au contrôle de la réalisation effective d'une période de formation en milieu professionnel ouvrant droit au versement de l'allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel prévue par le décret N° 2023-765 du 11/08/2023.")

      composer.table(
        [
         ["Bénéficiaire", "#{@student.full_name}, né(e) le #{I18n.l(@student.birthdate, format: :long)}, #{address_copy}"],
         ["Décision d'attribution annuelle", @schooling.attributive_decision_number],
         ["Numéro de prestation dossier", @pfmp.administrative_number],
         ["Période d'attribution (année scolaire)", @school_year],
         ["Période visée par l'état liquidatif", "#{@pfmp.start_date.strftime("%d/%m/%Y")} - #{@pfmp.end_date.strftime("%d/%m/%Y")}"],
         ["Montant à verser (calcul)", "#{@amount}€"],
         ["Ministère financeur et programme concerné", @schooling.mef.ministry],
         ["Coordonnées de paiement : IBAN", @rib&.iban],
         ["Coordonnées de paiement : BIC", @rib&.bic],
         ["Coordonnées de paiement : Titulaire du compte", @rib&.name],
        ]
      )

      date = @pfmp.transitions.find_by(to_state: @state).created_at.strftime("%d/%m/%Y")
      composer.text("Etat liquidatif édité le #{date} par validation informatique du responsable légal de l'établissement")
    end

    def header
      header_initializer(@title, false)
    end

    def summary
      establishment = @schooling.establishment

      composer.text("Numéro de dossier administratif : #{@schooling.administrative_number}")
      composer.text("Numéro de décision attributive annuelle : #{@schooling.attributive_decision_number}")
      composer.text("Bénéficiaire : #{@student}")
      composer.text("Numéro d'état liquidatif : #{@pfmp.administrative_number}")
      composer.text("Adresse email de l'établissement : #{establishment.email}")
      composer.text("Téléphone de l'établissement : #{establishment.telephone}")
      composer.text("#{confirmed_director.name}, représentant légal de l'établissement d'enseignement #{establishment.name}, (#{establishment.uai}), sis #{establishment.address}.", style: :paragraph)
    end
  end
end
# rubocop:enable all
