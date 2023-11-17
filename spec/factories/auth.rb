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

    initialize_with { [uai, type, category, function, uaj, tna_sym, tty_code, tna_code].join("$") }
  end

  # rubocop:disable FactoryBot/FactoryAssociationWithStrategy

  factory :freduresdel, class: "String" do
    transient do
      uai { "0380083J" }
      tty_code { "LP" }
      resp_attribute { "FrEduRneResp" }
      applicationname { "aplypro" }
      fredurneresp { build(:fredurneresp, uai: uai, tty_code: tty_code) }

      name { "aplypro" }
      url { "/redirectionhub/redirect.jsp?applicationname=#{applicationname}" }
      begin_date { "18/10/2023" }
      end_date { "31/12/9999" }
      user_name { "user_name" }
      responsibilities { "#{resp_attribute}=#{fredurneresp}" }
      server_id { "server_id" }
      mod { "module" }
    end

    initialize_with { [name, url, begin_date, end_date, user_name, responsibilities, server_id, mod].join("|") }
  end

  # rubocop:enable FactoryBot/FactoryAssociationWithStrategy

  factory :freduresdel_multiple, class: "String" do
    transient do
      tty_code_per_uai do
        {
          "0490910Y" => "LP",
          "0492285T" => "LYC"
        }
      end
    end

    initialize_with do
      fredurneresp_multiple = tty_code_per_uai.map do |uai, tty_code|
        build(:fredurneresp, uai: uai, tty_code: tty_code)
      end.join(";")

      build(:freduresdel, fredurneresp: fredurneresp_multiple)
    end
  end
end
