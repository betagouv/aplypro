# frozen_string_literal: true

module DeveloperOidc
  extend ActiveSupport::Concern

  def oidcize_dev_hash(attrs)
    attrs.merge!(
      {
        provider: :fim,
        **static_info(attrs),
        **extra_info(attrs)
      }
    )
  end

  private

  def provider
    :fim
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

  def extra_info(attrs)
    uai = attrs["info"]["uai"]

    info = role(attrs) == :dir ? responsibility_hash(uai) : authorised_hash(uai)

    {
      extra: {
        raw_info: info
      }
    }
  end

  def authorised_hash(uai)
    { FrEduRne: ["#{uai}$UAJ$PU$ADM$111$T3$LYC$340"] }
  end

  def responsibility_hash(uai)
    {
      FrEduRneResp: ["#{uai}$UAJ$PU$N$T3$LYC$340"],
      FrEduFonctAdm: "DIR"
    }
  end
end
