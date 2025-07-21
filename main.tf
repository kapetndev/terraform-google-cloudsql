locals {
  has_replicas = length(var.replicas) > 0
  is_mysql     = can(regex("^MYSQL", var.database_version))
  is_postgres  = can(regex("^POSTGRES", var.database_version))
  is_regional  = var.availability_type == "REGIONAL" ? true : false

  # When not using a verbatim name, we generate a random ID to use as the
  # suffix for the instance name. This is to ensure that the name is unique
  # and does not conflict with any other instances in the project. An optional
  # prefix can be added to the name, which is useful for grouping instances.
  name   = "${local.prefix}${var.name}"
  prefix = var.prefix != null ? "${var.prefix}-" : ""

  # The minimum password length is set to 16 characters by default, but can be
  # overridden by the user. The password validation policy is applied to all
  # users, including the root user, and is enforced by the database engine.
  minimum_password_length = try(var.password_validation_policy.min_length, 16)

  databases = {
    for database in var.databases :
    database.name => database
  }

  # Users are defined as a map of username, as defined in the key, to user
  # object. For MySQL, anything after the first `@` (if present) in the username
  # will be used as the user's host.
  #
  # For BUILT_IN users, the password is generated if not provided.
  users = {
    for k, v in var.users : k =>
    local.is_mysql
    ? {
      host     = v.type == "BUILT_IN" ? try(split("@", k)[1], null) : null
      name     = v.type == "BUILT_IN" ? split("@", k)[0] : k
      password = v.type == "BUILT_IN" ? try(random_password.passwords[k].result, v.password) : null
      type     = v.type
    }
    : {
      host     = null
      name     = local.is_postgres ? try(trimsuffix(k, ".gserviceaccount.com"), k) : k
      password = v.type == "BUILT_IN" ? try(random_password.passwords[k].result, v.password) : null
      type     = v.type
    }
  }
}

# Generate a random password for each user that does not have a password set and
# is of type BUILT_IN. This prevents the need to manually set passwords for
# users.
#
# WARNING: The passwords are stored in plaintext in the state file and should be
# updated manually in the console or using the CLI. Doing so will not be
# considered drift.
resource "random_password" "passwords" {
  for_each    = toset([for k, v in var.users : k if v.password == null && v.type == "BUILT_IN"])
  length      = local.minimum_password_length
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
  special     = true
}

# Generate a random password for the root user if one is not provided.
#
# WARNING: The password is stored in plaintext in the state file and should be
# updated manually in the console or using the CLI. Doing so will not be
# considered drift.
resource "random_password" "root_password" {
  count       = var.root_password.random_password ? 1 : 0
  length      = local.minimum_password_length
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
  special     = true
}

resource "random_id" "database_name" {
  count       = var.descriptive_name == null ? 1 : 0
  byte_length = 4
  prefix      = "${local.name}-"
}

resource "google_sql_database_instance" "primary" {
  database_version    = var.database_version
  encryption_key_name = var.encryption_key_name
  name                = coalesce(var.descriptive_name, random_id.database_name[0].hex)
  project             = var.project_id
  region              = var.region
  root_password       = var.root_password.random_password ? random_password.root_password[0].result : var.root_password.password

  settings {
    activation_policy           = var.activation_policy
    availability_type           = var.availability_type
    connector_enforcement       = var.connector_enforcement
    deletion_protection_enabled = var.prevent_destroy
    disk_autoresize             = var.disk_size == null
    disk_autoresize_limit       = var.disk_autoresize_limit
    disk_size                   = var.disk_size
    disk_type                   = var.disk_type
    edition                     = var.edition
    tier                        = var.machine_type
    time_zone                   = var.time_zone
    user_labels                 = var.labels

    ip_configuration {
      allocated_ip_range                            = try(var.network_config.connectivity.psa_config.allocated_ip_range, null)
      enable_private_path_for_google_cloud_services = var.network_config.connectivity.enable_private_path_for_services
      ipv4_enabled                                  = var.network_config.connectivity.public_ipv4
      private_network                               = try(var.network_config.connectivity.psa_config.private_network, null)
      ssl_mode                                      = var.ssl.mode

      dynamic "authorized_networks" {
        for_each = var.network_config.authorized_networks
        iterator = network

        content {
          name  = network.key
          value = network.value
        }
      }
    }

    dynamic "backup_configuration" {
      for_each = var.backup_configuration.enabled ? [""] : []

      content {
        enabled = true
        # Enable binary log if the user asks for it or we have replicas
        # (default in regional), but only for MySQL.
        binary_log_enabled = (
          local.is_mysql
          ? var.backup_configuration.binary_log_enabled || local.has_replicas || local.is_regional
          : null
        )
        location                       = var.backup_configuration.location
        point_in_time_recovery_enabled = var.backup_configuration.point_in_time_recovery_enabled
        start_time                     = var.backup_configuration.start_time
        transaction_log_retention_days = var.backup_configuration.log_retention_days

        backup_retention_settings {
          retained_backups = var.backup_configuration.retention_count
          retention_unit   = "COUNT"
        }
      }
    }

    dynamic "data_cache_config" {
      for_each = var.edition == "ENTERPRISE_PLUS" ? [""] : []

      content {
        data_cache_enabled = var.data_cache
      }
    }

    dynamic "database_flags" {
      for_each = var.flags
      iterator = flag

      content {
        name  = flag.key
        value = flag.value
      }
    }

    dynamic "deny_maintenance_period" {
      for_each = var.maintenance_config.deny_maintenance_period != null ? [""] : []

      content {
        end_date   = var.maintenance_config.deny_maintenance_period.end_date
        start_date = var.maintenance_config.deny_maintenance_period.start_date
        time       = var.maintenance_config.deny_maintenance_period.start_time
      }
    }

    dynamic "insights_config" {
      for_each = var.insights_config != null ? [""] : []

      content {
        query_insights_enabled  = true
        query_plans_per_minute  = var.insights_config.query_plans_per_minute
        query_string_length     = var.insights_config.query_string_length
        record_application_tags = var.insights_config.record_application_tags
        record_client_address   = var.insights_config.record_client_address
      }
    }

    dynamic "location_preference" {
      for_each = var.location_preference != null ? [""] : []

      content {
        zone           = var.location_preference.zone
        secondary_zone = var.location_preference.secondary_zone
      }
    }

    dynamic "maintenance_window" {
      for_each = var.maintenance_config.maintenance_window != null ? [""] : []

      content {
        day          = var.maintenance_config.maintenance_window.day
        hour         = var.maintenance_config.maintenance_window.hour
        update_track = var.maintenance_config.maintenance_window.update_track
      }
    }

    dynamic "password_validation_policy" {
      for_each = var.password_validation_policy != null ? [""] : []

      content {
        complexity = (
          var.password_validation_policy.default_complexity == true
          ? "COMPLEXITY_DEFAULT"
          : null # "COMPLEXITY_UNSPECIFIED" generates a permadiff
        )
        disallow_username_substring = var.password_validation_policy.disallow_username_substring
        enable_password_policy      = var.password_validation_policy.enabled
        min_length                  = var.password_validation_policy.min_length
        password_change_interval = (
          var.password_validation_policy.change_interval == null
          ? null
          : "${var.password_validation_policy.change_interval}s"
        )
        reuse_interval = var.password_validation_policy.reuse_interval
      }
    }
  }
}

resource "google_sql_database_instance" "replicas" {
  for_each             = local.has_replicas ? var.replicas : {}
  database_version     = var.database_version
  encryption_key_name  = each.value.encryption_key_name
  master_instance_name = google_sql_database_instance.primary.name
  name                 = "${coalesce(var.descriptive_name, random_id.database_name[0].hex)}-${each.key}"
  project              = var.project_id
  region               = coalesce(each.value.region, var.region)

  settings {
    activation_policy           = var.activation_policy
    availability_type           = coalesce(each.value.availability_type, var.availability_type)
    connector_enforcement       = var.connector_enforcement
    deletion_protection_enabled = var.prevent_destroy
    disk_autoresize             = var.disk_size == null
    disk_autoresize_limit       = var.disk_autoresize_limit
    disk_size                   = var.disk_size
    disk_type                   = var.disk_type
    edition                     = var.edition
    tier                        = coalesce(each.value.machine_type, var.machine_type)
    time_zone                   = var.time_zone
    user_labels                 = merge(var.labels, coalesce(each.value.additional_labels, {}))

    ip_configuration {
      allocated_ip_range = try(var.network_config.connectivity.psa_config.allocated_ip_range, null)
      enable_private_path_for_google_cloud_services = coalesce(
        try(each.value.network_config.connectivity.enable_private_path_for_services, null),
        var.network_config.connectivity.enable_private_path_for_services
      )
      ipv4_enabled = coalesce(
        try(each.value.network_config.connectivity.public_ipv4, null),
        var.network_config.connectivity.public_ipv4
      )
      private_network = try(var.network_config.connectivity.psa_config.private_network, null)
      ssl_mode        = var.ssl.mode

      dynamic "authorized_networks" {
        for_each = coalesce(
          try(each.value.network_config.authorized_networks, null),
          var.network_config.authorized_networks,
          {}
        )
        iterator = network

        content {
          name  = network.key
          value = network.value
        }
      }
    }

    dynamic "data_cache_config" {
      for_each = var.edition == "ENTERPRISE_PLUS" ? [""] : []

      content {
        data_cache_enabled = var.data_cache
      }
    }

    dynamic "database_flags" {
      for_each = merge(var.flags, coalesce(each.value.additional_flags, {}))
      iterator = flag

      content {
        name  = flag.key
        value = flag.value
      }
    }
  }
}

resource "google_sql_database" "databases" {
  for_each  = local.databases
  charset   = each.value.charset
  collation = each.value.collation
  instance  = google_sql_database_instance.primary.name
  name      = each.value.name
  project   = var.project_id
}

resource "google_sql_ssl_cert" "client_certificates" {
  for_each    = var.ssl.client_certificates
  common_name = each.key
  instance    = google_sql_database_instance.primary.name
  project     = var.project_id
}

resource "google_sql_user" "users" {
  for_each = local.users
  host     = each.value.host
  instance = google_sql_database_instance.primary.name
  name     = each.value.name
  password = each.value.password
  project  = var.project_id
  type     = each.value.type
}
