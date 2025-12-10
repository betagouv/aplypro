# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength, Metrics/BlockLength, Metrics/AbcSize

module Keycloak
  class Client
    attr_reader :base_url, :admin_user, :admin_pass

    def initialize(base_url, admin_user, admin_pass)
      @base_url = base_url.chomp("/")
      @admin_user = admin_user
      @admin_pass = admin_pass
      @token = nil
    end

    def authenticate
      uri = URI("#{@base_url}/realms/master/protocol/openid-connect/token")
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(
        "grant_type" => "password",
        "client_id" => "admin-cli",
        "username" => @admin_user,
        "password" => @admin_pass
      )

      response = http_request(uri, request)
      data = JSON.parse(response.body)
      @token = data["access_token"]
      puts "✓ Authenticated successfully"
      @token
    rescue StandardError => e
      raise "Authentication failed: #{e.message}"
    end

    def get(path)
      make_request(Net::HTTP::Get, path)
    end

    def post(path, body)
      make_request(Net::HTTP::Post, path, body)
    end

    def put(path, body)
      make_request(Net::HTTP::Put, path, body)
    end

    def find_client_id(realm_name, client_id)
      clients = get("/admin/realms/#{realm_name}/clients?clientId=#{client_id}")
      clients.first["id"] if clients&.any?
    end

    def find_client_scope_id(realm_name, scope_name)
      scopes = get("/admin/realms/#{realm_name}/client-scopes")
      scope = scopes.find { |s| s["name"] == scope_name }
      scope["id"] if scope
    end

    private

    def make_request(method_class, path, body = nil)
      authenticate if @token.nil?

      uri = URI("#{@base_url}#{path}")
      request = build_request(method_class, uri, body)
      response = http_request(uri, request)

      return parse_response(response) unless response.code.to_i == 401

      authenticate
      request["Authorization"] = "Bearer #{@token}"
      response = http_request(uri, request)
      parse_response(response)
    end

    def build_request(method_class, uri, body)
      request = method_class.new(uri)
      request["Authorization"] = "Bearer #{@token}"
      request["Content-Type"] = "application/json"
      request.body = body.to_json if body
      request
    end

    def parse_response(response)
      return {} if response.body.blank?

      JSON.parse(response.body)
    rescue JSON::ParserError
      response.body
    end

    def http_request(uri, request)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        response = http.request(request)

        raise "HTTP 409: #{response.body}" if response.code.to_i == 409
        raise "HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

        response
      end
    end
  end

  class Exporter
    BUILT_IN_CLIENTS = %w[
      account account-console admin-cli broker realm-management security-admin-console
    ].freeze
    BUILT_IN_ROLES = %w[offline_access uma_authorization].freeze
    BUILT_IN_CLIENT_SCOPES = %w[
      web-origins acr roles profile email address phone offline_access microprofile-jwt
    ].freeze

    def initialize(client, realm_name)
      @client = client
      @realm_name = realm_name
    end

    def export
      puts "\n=== Exporting realm: #{@realm_name} ==="

      export_data = {
        "realm" => export_with_message("realm configuration", "/admin/realms/#{@realm_name}"),
        "identityProviders" => export_identity_providers,
        "clientScopes" => export_client_scopes,
        "clients" => export_clients,
        "roles" => export_roles,
        "authenticationFlows" => export_flows
      }

      puts "✓ Export completed"
      export_data
    end

    private

    def export_identity_providers
      export_collection(
        "identity providers",
        "/admin/realms/#{@realm_name}/identity-provider/instances"
      )
    end

    def export_client_scopes
      export_collection("client scopes", "/admin/realms/#{@realm_name}/client-scopes") do |scopes|
        filter_built_in_client_scopes(scopes)
      end
    end

    def export_clients
      export_collection("clients", "/admin/realms/#{@realm_name}/clients") do |clients|
        filter_built_in_clients(clients)
      end
    end

    def export_roles
      export_collection("roles", "/admin/realms/#{@realm_name}/roles") do |roles|
        filter_built_in_roles(roles)
      end
    end

    def export_with_message(description, path)
      puts "  Exporting #{description}..."
      data = @client.get(path)
      puts "  ✓ #{description.capitalize} exported"
      data
    end

    def export_collection(description, path)
      puts "  Exporting #{description}..."
      data = @client.get(path)
      data = yield(data) if block_given?
      count = data.is_a?(Array) ? data.length : 1
      suffix = block_given? ? " (built-in #{description} excluded)" : ""
      puts "  ✓ #{count} #{description} exported#{suffix}"
      data
    end

    def export_flows
      export_collection("authentication flows", "/admin/realms/#{@realm_name}/authentication/flows") do |flows|
        flows.reject { |flow| flow["builtIn"] }
      end
    rescue StandardError => e
      puts "  ⚠ Could not export authentication flows: #{e.message}"
      []
    end

    def filter_built_in_clients(clients)
      clients.reject { |client| BUILT_IN_CLIENTS.include?(client["clientId"]) }
    end

    def filter_built_in_roles(roles)
      roles.reject { |role| BUILT_IN_ROLES.include?(role["name"]) || role["name"] == "default-roles-#{@realm_name}" }
    end

    def filter_built_in_client_scopes(scopes)
      scopes.reject { |scope| BUILT_IN_CLIENT_SCOPES.include?(scope["name"]) }
    end
  end

  class Importer
    def initialize(client, export_data)
      @client = client
      @export_data = export_data
      @realm_name = export_data["realm"]["realm"]
    end

    def import
      puts "\n=== Importing realm: #{@realm_name} ==="

      import_realm
      import_roles
      import_identity_providers
      import_client_scopes
      import_clients
      import_authentication_flows

      puts "✓ Import completed"
    end

    private

    def import_realm
      puts "  Creating/updating realm..."

      existing_realms = @client.get("/admin/realms")
      realm_exists = existing_realms.any? { |r| r["realm"] == @realm_name }

      if realm_exists
        update_existing_realm
      else
        create_new_realm
      end
    rescue StandardError => e
      puts "  ⚠ Error with realm: #{e.message}"
      raise
    end

    def update_existing_realm
      puts "  ℹ Realm already exists, updating configuration..."
      @client.put("/admin/realms/#{@realm_name}", @export_data["realm"])
      puts "  ✓ Realm updated"
    end

    def create_new_realm
      realm_data = @export_data["realm"].dup
      realm_data.delete("id")
      @client.post("/admin/realms", realm_data)
      puts "  ✓ Realm created"
    end

    def import_roles
      import_collection("roles", @export_data["roles"], :name) do |role|
        role.delete("id")
        @client.post("/admin/realms/#{@realm_name}/roles", role)
      end
    end

    def import_identity_providers
      puts "  Importing identity providers..."
      return if @export_data["identityProviders"].blank?

      @export_data["identityProviders"].each do |provider|
        import_identity_provider(provider)
      end
    end

    def import_identity_provider(provider)
      provider_data = provider.dup
      provider_data.delete("internalId")

      create_or_update(
        "Identity provider '#{provider['alias']}'",
        -> { @client.post("/admin/realms/#{@realm_name}/identity-provider/instances", provider_data) },
        lambda {
          @client.put(
            "/admin/realms/#{@realm_name}/identity-provider/instances/#{provider['alias']}",
            provider_data
          )
        }
      )
    end

    def import_client_scopes
      puts "  Importing client scopes..."
      return if @export_data["clientScopes"].blank?

      @export_data["clientScopes"].each do |scope|
        import_client_scope(scope)
      end
    end

    def import_client_scope(scope)
      scope_data = scope.dup
      scope_data.delete("id")
      scope_name = scope["name"]

      create_or_update(
        "Client scope '#{scope_name}'",
        -> { @client.post("/admin/realms/#{@realm_name}/client-scopes", scope_data) },
        lambda {
          internal_id = @client.find_client_scope_id(@realm_name, scope_name)
          @client.put("/admin/realms/#{@realm_name}/client-scopes/#{internal_id}", scope_data)
        }
      )
    end

    def import_clients
      puts "  Importing clients..."
      return if @export_data["clients"].blank?

      @export_data["clients"].each do |client|
        import_client(client)
      end
    end

    def import_client(client)
      client_data = client.dup
      client_data.delete("id")
      client_id = client["clientId"]

      create_or_update(
        "Client '#{client_id}'",
        -> { @client.post("/admin/realms/#{@realm_name}/clients", client_data) },
        lambda {
          internal_id = @client.find_client_id(@realm_name, client_id)
          @client.put("/admin/realms/#{@realm_name}/clients/#{internal_id}", client_data)
        }
      )
    end

    def import_authentication_flows
      import_collection("authentication flows", @export_data["authenticationFlows"], :alias) do |flow|
        flow.delete("id")
        @client.post("/admin/realms/#{@realm_name}/authentication/flows", flow)
      end
    rescue StandardError => e
      puts "  ⚠ Could not import authentication flows: #{e.message}"
    end

    def import_collection(type, items, name_key)
      puts "  Importing #{type}..."
      return if items.blank?

      items.each do |item|
        import_collection_item(type, item, name_key)
      end
    end

    def import_collection_item(type, item, name_key)
      item_data = item.dup
      name = item[name_key.to_s]

      yield(item_data)
      puts "    ✓ #{type.capitalize.chop} '#{name}' created"
    rescue StandardError => e
      handle_collection_item_error(type, name, e)
    end

    def handle_collection_item_error(type, name, error)
      if error.message.include?("409")
        puts "    ℹ #{type.capitalize.chop} '#{name}' already exists, skipping"
      else
        puts "    ⚠ Error creating #{type.chop} '#{name}': #{error.message}"
      end
    end

    def create_or_update(name, create_action, update_action)
      create_action.call
      puts "    ✓ #{name} created"
    rescue StandardError => e
      handle_create_or_update_error(name, e, update_action)
    end

    def handle_create_or_update_error(name, error, update_action)
      if error.message.include?("409")
        puts "    ℹ #{name} already exists, updating..."
        update_action.call
        puts "    ✓ #{name} updated"
      else
        puts "    ⚠ Error creating #{name}: #{error.message}"
      end
    rescue StandardError => e
      puts "    ⚠ Error updating #{name}: #{e.message}"
    end
  end
end

namespace :keycloak do
  desc "Export all realms - rake keycloak:export[source_url,admin_user,admin_pass]"
  task :export, %i[source_url admin_user admin_pass] => :environment do |_t, args|
    unless args[:source_url] && args[:admin_user] && args[:admin_pass]
      abort "Error: source_url, admin_user, and admin_pass are required"
    end

    client = Keycloak::Client.new(args[:source_url], args[:admin_user], args[:admin_pass])
    export_all_realms(client)
  end

  desc "Import realm - rake keycloak:import[target_url,admin_user,admin_pass,input_file]"
  task :import, %i[target_url admin_user admin_pass input_file] => :environment do |_t, args|
    unless args[:target_url] && args[:admin_user] && args[:admin_pass] && args[:input_file]
      abort "Error: target_url, admin_user, admin_pass, and input_file are required"
    end

    abort "Error: Input file not found: #{args[:input_file]}" unless File.exist?(args[:input_file])

    export_data = JSON.parse(File.read(args[:input_file]))

    client = Keycloak::Client.new(args[:target_url], args[:admin_user], args[:admin_pass])
    importer = Keycloak::Importer.new(client, export_data)

    importer.import
    puts "\n✓ Import completed successfully"
  end

  def export_all_realms(client)
    puts "\n=== Fetching all realms ==="
    realms = client.get("/admin/realms")

    realm_names = realms.map { |r| r["realm"] }.reject { |name| name == "master" }

    if realm_names.empty?
      puts "No realms to export (excluding master)"
      return
    end

    puts "Found #{realm_names.length} realm(s) to export: #{realm_names.join(', ')}"

    realm_names.each do |realm_name|
      exporter = Keycloak::Exporter.new(client, realm_name)
      export_data = exporter.export
      output_file = "#{realm_name}-export.json"

      File.write(output_file, JSON.pretty_generate(export_data))
      puts "\n✓ Export saved to: #{output_file}"
    end

    puts "\n✓ All realms exported successfully"
  end
end

# rubocop:enable Metrics/ClassLength, Metrics/BlockLength, Metrics/AbcSize
