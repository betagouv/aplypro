# frozen_string_literal: true

module DeveloperOidc
  extend ActiveSupport::Concern

  def oidcize_dev_hash(attrs)
    attrs.merge!(
      {
        **provider_info(attrs),
        **static_info(attrs),
        **extra_info(attrs)
      }
    )
  end

  private

  def provider(attrs)
    case attrs["info"]["Portail de connexion"]
    when /MASA/
      :masa
    else
      :fim
    end
  end

  def role(attrs)
    case attrs["info"]["Role assumé"]
    when /direction/
      :dir
    else
      :authorised
    end
  end

  def static_info(attrs)
    {
      "credentials" => {
        "token" => "dev token"
      },
      "uid" => attrs["info"]["email"],
      "info" => {
        "name" => "Developer Account",
        "email" => attrs["info"]["email"]
      }
    }
  end

  def provider_info(attrs)
    { "provider" => provider(attrs) }
  end

  def extra_info(attrs)
    uai = attrs["info"]["uai"]

    info = role(attrs) == :dir ? responsibility_hash(attrs, uai) : authorised_hash(attrs, uai)

    {
      extra: {
        raw_info: info
      }
    }
  end

  def authorised_hash(attrs, uai)
    line = ["#{uai}$UAJ$PU$N$T3$LYC$340"]

    if provider(attrs) == :fim
      { FrEduRne: line }
    else
      { attributes: { fr_edu_rne: line } }
    end
  end

  def responsibility_hash(attrs, uai)
    line = ["#{uai}$UAJ$PU$N$T3$LYC$340"]

    if provider(attrs) == :fim
      {
        FrEduRneResp: line,
        FrEduFonctAdm: "DIR"
      }
    else
      {
        attributes: {
          fr_edu_rne_resp: line,
          fr_edu_fonct_adm: "DIR"
        }
      }
    end
  end
end
