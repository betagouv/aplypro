# frozen_string_literal: true

module Keycloak
  class Exporter
    BUILT_IN_CLIENTS = %w[
      account account-console admin-cli broker realm-management security-admin-console
    ].freeze
    BUILT_IN_ROLES = %w[offline_access uma_authorization].freeze
    BUILT_IN_CLIENT_SCOPES = %w[
      web-origins acr roles profile email address phone offline_access microprofile-jwt
    ].freeze

    def initialize(client, realm_name, logger: Logger.new($stdout))
      @client = client
      @realm_name = realm_name
      @logger = logger
    end

    def export
      @logger.info "\n=== Exporting realm: #{@realm_name} ==="

      export_data = {
        "realm" => export_with_message("realm configuration", "/admin/realms/#{@realm_name}"),
        "identityProviders" => export_identity_providers,
        "clientScopes" => export_client_scopes,
        "clients" => export_clients,
        "roles" => export_roles,
        "authenticationFlows" => export_flows
      }

      @logger.info "✓ Export completed"
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
      @logger.info "  Exporting #{description}..."
      data = @client.get(path)
      @logger.info "  ✓ #{description.capitalize} exported"
      data
    end

    def export_collection(description, path)
      @logger.info "  Exporting #{description}..."
      data = @client.get(path)
      data = yield(data) if block_given?
      count = data.is_a?(Array) ? data.length : 1
      suffix = block_given? ? " (built-in #{description} excluded)" : ""
      @logger.info "  ✓ #{count} #{description} exported#{suffix}"
      data
    end

    def export_flows
      export_collection("authentication flows", "/admin/realms/#{@realm_name}/authentication/flows") do |flows|
        flows.reject { |flow| flow["builtIn"] }
      end
    rescue StandardError => e
      @logger.warn "  ⚠ Could not export authentication flows: #{e.message}"
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
end
