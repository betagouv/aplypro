# frozen_string_literal: true

module Keycloak
  class Exporter # rubocop:disable Metrics/ClassLength
    BUILT_IN_CLIENTS = %w[
      account account-console admin-cli broker realm-management security-admin-console
    ].freeze
    BUILT_IN_ROLES = %w[offline_access uma_authorization].freeze
    BUILT_IN_CLIENT_SCOPES = %w[
      web-origins acr roles profile email address phone offline_access microprofile-jwt
    ].freeze
    BUILT_IN_COMPONENT_PROVIDERS = %w[
      allowed-client-templates allowed-protocol-mappers trusted-hosts consent-required scope
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
        "userProfile" => export_user_profile,
        "identityProviders" => export_identity_providers,
        "clientScopes" => export_client_scopes,
        "clients" => export_clients,
        "roles" => export_roles,
        "groups" => export_groups,
        "components" => export_components,
        "requiredActions" => export_required_actions,
        "defaultDefaultClientScopes" => export_default_default_client_scopes,
        "authenticationFlows" => export_flows,
        "authenticatorConfigs" => export_authenticator_configs
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
      export_collection("authentication flows", "/admin/realms/#{@realm_name}/authentication/flows")
    rescue StandardError => e
      @logger.warn "  ⚠ Could not export authentication flows: #{e.message}"
      []
    end

    def export_authenticator_configs
      config_ids = fetch_authenticator_config_ids
      return [] if config_ids.empty?

      @logger.info "  Exporting authenticator configs..."
      configs = fetch_configs_by_ids(config_ids)
      @logger.info "  ✓ #{configs.length} authenticator config(s) exported"
      configs
    rescue StandardError => e
      @logger.warn "  ⚠ Could not export authenticator configs: #{e.message}"
      []
    end

    def fetch_authenticator_config_ids
      flows = @client.get("/admin/realms/#{@realm_name}/authentication/flows")
      flows.flat_map do |flow|
        (flow["authenticationExecutions"] || []).map { |exec| exec["authenticatorConfig"] }.compact
      end.uniq
    end

    def fetch_configs_by_ids(config_ids)
      config_ids.map do |config_id|
        fetch_single_config(config_id)
      end.compact
    end

    def fetch_single_config(config_id)
      encoded_config_id = CGI.escape(config_id)
      response = @client.get("/admin/realms/#{@realm_name}/authentication/config/#{encoded_config_id}")

      return nil if response.is_a?(Hash) && response["error"]

      response
    rescue StandardError => e
      @logger.warn "    ⚠ Could not export config #{config_id}: #{e.message}"
      nil
    end

    def export_user_profile
      export_with_message("user profile configuration", "/admin/realms/#{@realm_name}/users/profile")
    rescue StandardError => e
      @logger.warn "  ⚠ Could not export user profile: #{e.message}"
      nil
    end

    def export_groups
      export_collection("groups", "/admin/realms/#{@realm_name}/groups")
    rescue StandardError => e
      @logger.warn "  ⚠ Could not export groups: #{e.message}"
      []
    end

    def export_components
      export_collection("components", "/admin/realms/#{@realm_name}/components") do |components|
        filter_built_in_components(components)
      end
    rescue StandardError => e
      @logger.warn "  ⚠ Could not export components: #{e.message}"
      []
    end

    def export_required_actions
      export_collection("required actions", "/admin/realms/#{@realm_name}/authentication/required-actions")
    rescue StandardError => e
      @logger.warn "  ⚠ Could not export required actions: #{e.message}"
      []
    end

    def export_default_default_client_scopes
      export_collection(
        "default default client scopes",
        "/admin/realms/#{@realm_name}/default-default-client-scopes"
      )
    rescue StandardError => e
      @logger.warn "  ⚠ Could not export default default client scopes: #{e.message}"
      []
    end

    def filter_built_in_components(components)
      components.reject do |component|
        built_in_provider?(component) || fallback_component?(component)
      end
    end

    def built_in_provider?(component)
      BUILT_IN_COMPONENT_PROVIDERS.include?(component["providerId"])
    end

    def fallback_component?(component)
      component["name"]&.start_with?("fallback-")
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
