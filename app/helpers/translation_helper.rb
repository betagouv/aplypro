# frozen_string_literal: true

module TranslationHelper
  def hint_for(klass, attribute)
    I18n.t("activerecord.hints.#{klass.model_name.element}.#{attribute}", default: nil)
  end

  def save_label(klass)
    cod = save_label_cod(klass)

    I18n.t("activerecord.save_label", cod: cod)
  end

  def save_label_cod(klass)
    I18n.t("activerecord.save_labels.#{klass.model_name.element}", default: "de la ressource")
  end
end
