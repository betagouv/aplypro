# frozen_string_literal: true

require_relative "../keycloak/client"
require_relative "../keycloak/exporter"
require_relative "../keycloak/importer"

namespace :keycloak do # rubocop:disable Metrics/BlockLength
  desc "Export all realms - rake keycloak:export[source_url,admin_user,admin_pass]"
  task :export, %i[source_url admin_user admin_pass] => :environment do |_t, args|
    unless args[:source_url] && args[:admin_user] && args[:admin_pass]
      abort "Error: source_url, admin_user, and admin_pass are required"
    end

    logger = Logger.new($stdout)
    client = Keycloak::Client.new(args[:source_url], args[:admin_user], args[:admin_pass])
    export_all_realms(client, logger)
  end

  desc "Import realm - rake keycloak:import[target_url,admin_user,admin_pass,input_file]"
  task :import, %i[target_url admin_user admin_pass input_file] => :environment do |_t, args|
    unless args[:target_url] && args[:admin_user] && args[:admin_pass] && args[:input_file]
      abort "Error: target_url, admin_user, admin_pass, and input_file are required"
    end

    abort "Error: Input file not found: #{args[:input_file]}" unless File.exist?(args[:input_file])

    export_data = JSON.parse(File.read(args[:input_file]))
    logger = Logger.new($stdout)

    client = Keycloak::Client.new(args[:target_url], args[:admin_user], args[:admin_pass])
    importer = Keycloak::Importer.new(client, export_data, logger: logger)

    importer.import
    logger.info "\n✓ Import completed successfully"
  end

  def export_all_realms(client, logger)
    logger.info "\n=== Fetching all realms ==="
    realm_names = fetch_realm_names(client, logger)

    return unless realm_names.any?

    logger.info "Found #{realm_names.length} realm(s) to export: #{realm_names.join(', ')}"
    realm_names.each { |realm_name| export_realm(client, realm_name, logger) }
    logger.info "\n✓ All realms exported successfully"
  end

  def fetch_realm_names(client, logger)
    realms = client.get("/admin/realms")
    realm_names = realms.map { |r| r["realm"] }.reject { |name| name == "master" }

    logger.info "No realms to export (excluding master)" if realm_names.empty?

    realm_names
  end

  def export_realm(client, realm_name, logger)
    exporter = Keycloak::Exporter.new(client, realm_name, logger: logger)
    export_data = exporter.export
    output_file = "#{realm_name}-export.json"

    File.write(output_file, JSON.pretty_generate(export_data))
    logger.info "\n✓ Export saved to: #{output_file}"
  end
end
