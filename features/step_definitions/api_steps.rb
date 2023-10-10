# frozen_string_literal: true

def setup_sygne_oauth!
  stub_request(:post, ENV.fetch("APLYPRO_SYGNE_TOKEN_URL"))
    .with(
      body: { "grant_type" => "client_credentials" },
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Content-Type" => "application/x-www-form-urlencoded"
      }
    )
    .to_return(
      status: 200,
      body: JSON.generate({ access_token: "foobar", token_type: "Bearer" }),
      headers: { "Content-Type" => "application/json" }
    )
end

def mock_sygne_students_with!(payload)
  setup_sygne_oauth!

  url = ENV.fetch("APLYPRO_SYGNE_URL")

  stub_request(:get, %r{#{url}/*})
    .with(
      headers: {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Authorization" => "Bearer foobar"
      }
    )
    .to_return(status: 200, body: payload, headers: {})
end

Sachantque("l'API SYGNE renvoie une liste d'élèves") do
  mock_sygne_students_with!(FactoryBot.build_list(:sygne_student, 10))
end

Sachantque("l'API SYGNE renvoie une liste d'élèves vide") do
  mock_sygne_students_with!([])
end
