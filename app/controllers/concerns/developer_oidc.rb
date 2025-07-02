# frozen_string_literal: true

module DeveloperOidc
  extend ActiveSupport::Concern

  def oidcize_dev_hash(attrs, extra = true) # rubocop:disable Style/OptionalBooleanParameter
    attrs.merge!(
      {
        **provider_info(attrs),
        **static_info(attrs)
      }
    )
    attrs.merge!(extra_info(attrs)) if extra
  end

  private

  def provider(attrs)
    case attrs["info"]["Portail de connexion"]
    when /MASA/
      :masa
    when /ASP/
      :asp
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
      credentials: {
        token: "dev token"
      },
      uid: attrs["info"]["email"],
      info: {
        name: "Developer Account",
        email: attrs["info"]["email"]
      }
    }
  end

  def provider_info(attrs)
    { provider: provider(attrs) }
  end

  def extra_info(attrs)
    if attrs["info"]["uai"].nil?
      info = { AplyproAcademieResp: attrs["info"]["academy_code"] }
    else
      uai = attrs["info"]["uai"]
      info = role(attrs) == :dir ? responsibility_hash(attrs, uai) : authorised_hash(attrs, uai)
    end

    {
      extra: {
        raw_info: info
      }
    }
  end

  def authorised_hash(attrs, uai)
    line = ["#{uai}$UAJ$PU$ADM$111$T3$LYC$340"]

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
