# frozen_string_literal: true

module DeveloperOidc
  extend ActiveSupport::Concern

  def oidcize_dev_hash(attrs)
    attrs.merge!(
      {
        **provider_info(attrs),
        **static_info,
        **extra_info(attrs)
      }
    )
  end

  private

  def static_info
    {
      "credentials" => {
        "token" => "dev token"
      },
      "uid" => "developer",
      "info" => {
        "name" => "Aplypo Dev",
        "email" => "aplypro-dev-#{rand(1000)}@beta.gouv.fr"
      }
    }
  end

  def provider_info(attrs)
    { "provider" => attrs["info"]["provider"] }
  end

  def extra_info(attrs)
    uai = attrs["info"]["uai"]

    {
      extra: {
        raw_info: {
          **responsibility_hash(attrs, uai)
        }
      }
    }
  end

  def responsibility_hash(attrs, uai)
    line = ["#{uai}$UAJ$PU$N$T3$LYC$340"]

    if attrs["info"]["provider"] == "fim"
      { FrEduRneResp: line }
    else
      { attributes: { fr_edu_rne_resp: line } }
    end
  end
end
