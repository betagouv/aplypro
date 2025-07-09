# frozen_string_literal: true

require "hexapdf"

module Generator
  class Document
    include ActionView::Helpers::NumberHelper

    attr_reader :composer, :schooling, :student, :school_year

    def initialize(schooling)
      @composer = HexaPDF::Composer.new(page_size: :A4, margin: margin)
      @schooling = schooling
      @student = schooling.student
      @school_year = schooling.classe.school_year
    end

    def write
      io = StringIO.new
      render
      composer.write(io)
      io.rewind
      io
    end

    protected

    # rubocop:disable Layout/LineLength
    # rubocop:disable Style/OptionalBooleanParameter
    def header_initializer(title, feminine = true)
      composer.image(Rails.root.join("app/assets/images/Republique_Francaise_RVB.png").to_s, height: 100, position: :float)
      composer.text(title.upcase, style: :title, margin: [150, 0, 0, 0])
      composer.text("#{feminine ? 'Relative' : 'Relatif'} au versement d’une allocation en faveur des lycéens de la voie professionnelle dans le cadre de la valorisation des périodes de formation en milieu professionnel".upcase, style: :subtitle)
      composer.text("année scolaire #{@school_year}".upcase, style: :subtitle, margin: [10, 0, 50, 0])
    end
    # rubocop:enable Layout/LineLength
    # rubocop:enable Style/OptionalBooleanParameter

    private

    def margin
      48
    end

    def render
      setup_styles
      header
      summary
      legal
      articles
    end

    def setup_styles
      composer.style(:base, font: "Times", font_size: 10, line_spacing: 1.4, last_line_gap: true, margin: [3, 0, 0, 0])
      composer.style(:title, font: ["Times", { variant: :bold }], font_size: 12, align: :center, padding: [10, 0])
      composer.style(:direction, font_size: 12, align: :right)
      composer.style(:subtitle, align: :center, padding: [0, 30], line_height: 12)
      composer.style(:paragraph_title, font: ["Times", { variant: :bold }], font_size: 10, margin: [10, 0, 0, 0])
      composer.style(:paragraph, font_size: 10, margin: [5, 0, 0, 0])
      composer.style(:legal, font: ["Times", { variant: :italic }], padding: [10, 0, 0, 0])
    end

    def header; end
    def summary; end

    def address_copy
      if student.missing_address?
        I18n.t("attributive_decision.missing_address")
      else
        I18n.t("attributive_decision.address", address: student.address)
      end
    end

    def legal
      I18n.t("attributive_decision.legal").map { |line| composer.text("#{line} ;", style: :legal) }
    end
  end
end
