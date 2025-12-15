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
      import_user_profile
      import_roles
      import_identity_providers
      import_client_scopes
      import_clients
      import_groups
      import_components
      import_required_actions
      import_default_default_client_scopes
      import_authentication_flows
      import_authenticator_configs

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

    def import_authenticator_configs
      @logger.info "  Importing authenticator configs..."
      return if @export_data["authenticatorConfigs"].blank?

      @export_data["authenticatorConfigs"].each do |config|
        import_authenticator_config(config)
      end
    rescue StandardError => e
      @logger.warn "  ⚠ Could not import authenticator configs: #{e.message}"
    end

    def import_authenticator_config(config)
      config_data = config.dup
      config_data.delete("id")
      config_alias = config["alias"]

      @client.post("/admin/realms/#{@realm_name}/authentication/config", config_data)
      @logger.info "    ✓ Authenticator config '#{config_alias}' created"
    rescue StandardError => e
      if e.message.include?("409")
        @logger.info "    ℹ Authenticator config '#{config_alias}' already exists, skipping"
      else
        @logger.error "    ⚠ Error creating authenticator config '#{config_alias}': #{e.message}"
      end
    end

    def import_user_profile
      @logger.info "  Importing user profile configuration..."
      return if @export_data["userProfile"].blank?

      @client.put("/admin/realms/#{@realm_name}/users/profile", @export_data["userProfile"])
      @logger.info "  ✓ User profile configuration imported"
    rescue StandardError => e
      @logger.warn "  ⚠ Could not import user profile: #{e.message}"
    end

    def import_groups
      @logger.info "  Importing groups..."
      return if @export_data["groups"].blank?

      @export_data["groups"].each do |group|
        import_group(group)
      end
    rescue StandardError => e
      @logger.warn "  ⚠ Could not import groups: #{e.message}"
    end

    def import_group(group)
      group_data = group.dup
      group_data.delete("id")
      group_name = group["name"]

      create_or_update(
        "Group '#{group_name}'",
        -> { @client.post("/admin/realms/#{@realm_name}/groups", group_data) },
        lambda {
          group_id = find_group_id(group_name)
          @client.put("/admin/realms/#{@realm_name}/groups/#{group_id}", group_data) if group_id
        }
      )
    end

    def find_group_id(group_name)
      groups = @client.get("/admin/realms/#{@realm_name}/groups")
      group = groups.find { |g| g["name"] == group_name }
      group["id"] if group
    end

    def import_components
      @logger.info "  Importing components..."
      return if @export_data["components"].blank?

      @export_data["components"].each do |component|
        import_component(component)
      end
    rescue StandardError => e
      @logger.warn "  ⚠ Could not import components: #{e.message}"
    end

    def import_component(component)
      component_data = component.dup
      component_data.delete("id")
      component_name = component["name"]

      create_or_update(
        "Component '#{component_name}'",
        -> { @client.post("/admin/realms/#{@realm_name}/components", component_data) },
        lambda {
          component_id = find_component_id(component_name)
          @client.put("/admin/realms/#{@realm_name}/components/#{component_id}", component_data) if component_id
        }
      )
    end

    def find_component_id(component_name)
      components = @client.get("/admin/realms/#{@realm_name}/components")
      component = components.find { |c| c["name"] == component_name }
      component["id"] if component
    end

    def import_required_actions
      @logger.info "  Importing required actions..."
      return if @export_data["requiredActions"].blank?

      @export_data["requiredActions"].each do |action|
        import_required_action(action)
      end
    rescue StandardError => e
      @logger.warn "  ⚠ Could not import required actions: #{e.message}"
    end

    def import_required_action(action)
      action_data = action.dup
      action_alias = action["alias"]

      @client.put("/admin/realms/#{@realm_name}/authentication/required-actions/#{action_alias}", action_data)
      @logger.info "    ✓ Required action '#{action_alias}' updated"
    rescue StandardError => e
      @logger.error "    ⚠ Error updating required action '#{action_alias}': #{e.message}"
    end

    def import_default_default_client_scopes
      @logger.info "  Importing default default client scopes..."
      return if @export_data["defaultDefaultClientScopes"].blank?

      @export_data["defaultDefaultClientScopes"].each do |scope|
        import_default_default_client_scope(scope)
      end
    rescue StandardError => e
      @logger.warn "  ⚠ Could not import default default client scopes: #{e.message}"
    end

    def import_default_default_client_scope(scope)
      scope_id = @client.find_client_scope_id(@realm_name, scope["name"])
      return unless scope_id

      @client.put("/admin/realms/#{@realm_name}/default-default-client-scopes/#{scope_id}", {})
      @logger.info "    ✓ Default default client scope '#{scope['name']}' added"
    rescue StandardError => e
      @logger.error "    ⚠ Error adding default default client scope '#{scope['name']}': #{e.message}"
    end

    def import_collection(type, items, name_key, &block)
      @logger.info "  Importing #{type}..."
      return if items.blank?

      items.each do |item|
        import_collection_item(type, item, name_key, &block)
      end
    end

    def import_collection_item(type, item, name_key, &block)
      item_data = item.dup
      name = item[name_key.to_s]

      block.call(item_data)
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
