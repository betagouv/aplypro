# frozen_string_literal: true

module MefDecorator
  def to_s
    [code, short, label].join(" - ")
  end

  def specialty
    label.split.drop(1).join(" ")
  end

  def index
    label.split.first
  end

  def category
    I18n.t("mefs.labels.#{index}")
  end
end
