# frozen_string_literal: true

module Keycloak
  class Importer # rubocop:disable Metrics/ClassLength
    def initialize(client, export_data, logger: Logger.new($stdout))
      @client = client
      @export_data = export_data
      @realm_name = export_data["realm"]["realm"]
      @logger = logger
    end

    def import
      @logger.info "\n=== Importing realm: #{@realm_name} ==="

      import_realm
      import_roles
      import_identity_providers
      import_client_scopes
      import_clients
      import_authentication_flows

      @logger.info "✓ Import completed"
    end

    private

    def import_realm
      @logger.info "  Creating/updating realm..."

      existing_realms = @client.get("/admin/realms")
      realm_exists = existing_realms.any? { |r| r["realm"] == @realm_name }

      if realm_exists
        update_existing_realm
      else
        create_new_realm
      end
    rescue StandardError => e
      @logger.error "  ⚠ Error with realm: #{e.message}"
      raise
    end

    def update_existing_realm
      @logger.info "  ℹ Realm already exists, updating configuration..."
      @client.put("/admin/realms/#{@realm_name}", @export_data["realm"])
      @logger.info "  ✓ Realm updated"
    end

    def create_new_realm
      realm_data = @export_data["realm"].dup
      realm_data.delete("id")
      @client.post("/admin/realms", realm_data)
      @logger.info "  ✓ Realm created"
    end

    def import_roles
      import_collection("roles", @export_data["roles"], :name) do |role|
        role.delete("id")
        @client.post("/admin/realms/#{@realm_name}/roles", role)
      end
    end

    def import_identity_providers
      @logger.info "  Importing identity providers..."
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
      @logger.info "  Importing client scopes..."
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
      @logger.info "  Importing clients..."
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
      @logger.warn "  ⚠ Could not import authentication flows: #{e.message}"
    end

    def import_collection(type, items, name_key)
      @logger.info "  Importing #{type}..."
      return if items.blank?

      items.each do |item|
        import_collection_item(type, item, name_key)
      end
    end

    def import_collection_item(type, item, name_key)
      item_data = item.dup
      name = item[name_key.to_s]

      yield(item_data)
      @logger.info "    ✓ #{type.capitalize.chop} '#{name}' created"
    rescue StandardError => e
      handle_collection_item_error(type, name, e)
    end

    def handle_collection_item_error(type, name, error)
      if error.message.include?("409")
        @logger.info "    ℹ #{type.capitalize.chop} '#{name}' already exists, skipping"
      else
        @logger.error "    ⚠ Error creating #{type.chop} '#{name}': #{error.message}"
      end
    end

    def create_or_update(name, create_action, update_action)
      create_action.call
      @logger.info "    ✓ #{name} created"
    rescue StandardError => e
      handle_create_or_update_error(name, e, update_action)
    end

    def handle_create_or_update_error(name, error, update_action)
      if error.message.include?("409")
        @logger.info "    ℹ #{name} already exists, updating..."
        update_action.call
        @logger.info "    ✓ #{name} updated"
      else
        @logger.error "    ⚠ Error creating #{name}: #{error.message}"
      end
    rescue StandardError => e
      @logger.error "    ⚠ Error updating #{name}: #{e.message}"
    end
  end
end
