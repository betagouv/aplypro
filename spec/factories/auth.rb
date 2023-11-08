# frozen_string_literal: true

FactoryBot.define do
  factory :fredurneresp, class: "String" do
    transient do
      uai { "123" }
      type { "UAJ" }
      category { "PU" }
      activity { "N" }
      tna_sym { "T3" }
      tty_code { "LYC" }
      tna_code { "340" }
    end

    initialize_with { [uai, type, category, activity, tna_sym, tty_code, tna_code].join("$") }
  end

  factory :fredurne, class: "String" do
    transient do
      uai { "123" }
      type { "UAJ" }
      category { "PU" }
      function { "ADM" }
      uaj { "456" }
      tna_sym { "T3" }
      tty_code { "LYC" }
      tna_code { "340" }
    end

    initialize_with { [uai, type, category, function, activity, tna_sym, tty_code, tna_code].join("$") }
  end
end
