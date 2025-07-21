variable "activation_policy" {
  description = "This variable specifies when the instance should be active. Can be either ALWAYS, NEVER or ON_DEMAND. Default is ALWAYS."
  type        = string
  default     = "ALWAYS"
  nullable    = false
  validation {
    condition     = contains(["NEVER", "ON_DEMAND", "ALWAYS"], var.activation_policy)
    error_message = "The variable activation_policy must be ALWAYS, NEVER or ON_DEMAND."
  }
}

variable "availability_type" {
  description = "Availability type for the primary replica. Either `ZONAL` or `REGIONAL`."
  type        = string
  default     = "ZONAL"
  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "The variable availability_type must be ZONAL or REGIONAL."
  }
}

variable "backup_configuration" {
  description = <<EOF
Backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas.

(Optional) enabled - Whether backups are enabled.
(Optional) binary_log_enabled - Whether binary logging is enabled.
(Optional) start_time - The start time for the backup window, in 24 hour format.
(Optional) location - The location of the backup.
(Optional) log_retention_days - The number of days to retain transaction log files.
(Optional) point_in_time_recovery_enabled - Whether point in time recovery is enabled.
(Optional) retention_count - The number of backups to retain.
EOF
  type = object({
    enabled                        = optional(bool, false)
    binary_log_enabled             = optional(bool, false)
    start_time                     = optional(string, "23:00")
    location                       = optional(string)
    log_retention_days             = optional(number, 7)
    point_in_time_recovery_enabled = optional(bool)
    retention_count                = optional(number, 7)
  })
  default = {
    enabled                        = false
    binary_log_enabled             = false
    start_time                     = "23:00"
    location                       = null
    log_retention_days             = 7
    point_in_time_recovery_enabled = null
    retention_count                = 7
  }
  nullable = false
}

variable "collation" {
  description = "The name of server instance collation."
  type        = string
  default     = null
}

variable "connector_enforcement" {
  description = "Specifies if connections must use Cloud SQL connectors."
  type        = string
  default     = null
}

variable "data_cache" {
  description = "Enable data cache. Only used for Enterprise MYSQL and PostgreSQL."
  type        = bool
  default     = false
  nullable    = false
}

variable "database_version" {
  description = "Database type and version to create."
  type        = string
}

variable "databases" {
  description = "Databases to create once the primary instance is created."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "descriptive_name" {
  description = "The authoritative name of the cluster. Used instead of `name` variable."
  type        = string
  default     = null
}

variable "disk_autoresize_limit" {
  description = "The maximum size to which storage capacity can be automatically increased. The default value is 0, which specifies that there is no limit."
  type        = number
  default     = 0
}

variable "disk_size" {
  description = "Disk size in GB. Set to null to enable autoresize."
  type        = number
  default     = null
}

variable "disk_type" {
  description = "The type of data disk: `PD_SSD` or `PD_HDD`."
  type        = string
  default     = "PD_SSD"
  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.disk_type)
    error_message = "The variable disk_type must be PD_SSD or PD_HDD."
  }
}

variable "edition" {
  description = "The edition of the instance, can be ENTERPRISE or ENTERPRISE_PLUS."
  type        = string
  default     = "ENTERPRISE"
  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.edition)
    error_message = "The variable edition must be ENTERPRISE or ENTERPRISE_PLUS."
  }
}

variable "encryption_key_name" {
  description = "The full path to the encryption key used for the CMEK disk encryption of the primary instance."
  type        = string
  default     = null
}

variable "flags" {
  description = "Map FLAG_NAME=>VALUE for database-specific tuning."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "insights_config" {
  description = <<EOF
Query Insights configuration. Defaults to null which disables Query Insights.

(Optional) query_string_length - The maximum query string length. Default is 1024 characters.
(Optional) record_application_tags - Whether to record application tags.
(Optional) record_client_address - Whether to record client addresses.
(Optional) query_plans_per_minute - The number of query plans to generate per minute.
EOF
  type = object({
    query_string_length     = optional(number, 1024)
    record_application_tags = optional(bool, false)
    record_client_address   = optional(bool, false)
    query_plans_per_minute  = optional(number, 5)
  })
  default = null
}

variable "labels" {
  description = "User defined labels to assign to the instance."
  type        = map(string)
  default     = {}
}

variable "machine_type" {
  description = "The machine type to use for the instances."
  type        = string
}

variable "maintenance_config" {
  description = <<EOF
Set maintenance window configuration and maintenance deny period (up to 90 days). Date format: 'yyyy-mm-dd'.

(Optional) maintenance_window - The maintenance window configuration.
(Optional) maintenance_window.day - Day of week (1-7), starting with Monday.
(Optional) maintenance_window.hour - Hour of day (0-23).
(Optional) maintenance_window.update_track - The update track. Either 'canary' or 'stable'.
(Optional) deny_maintenance_period - The maintenance deny period.
(Optional) deny_maintenance_period.start_date - The start date in YYYY-MM-DD format.
(Optional) deny_maintenance_period.end_date - The end date in YYYY-MM-DD format.
(Optional) deny_maintenance_period.start_time - The start time in HH:MM:SS format.
EOF
  type = object({
    maintenance_window = optional(object({
      day          = number
      hour         = number
      update_track = optional(string, null)
    }), null)
    deny_maintenance_period = optional(object({
      start_date = string
      end_date   = string
      start_time = optional(string, "00:00:00")
    }), null)
  })
  default = {}
  validation {
    condition = (
      try(var.maintenance_config.maintenance_window, null) == null ? true : (
        # Maintenance window day validation below
        var.maintenance_config.maintenance_window.day >= 1 &&
        var.maintenance_config.maintenance_window.day <= 7 &&
        # Maintenance window hour validation below
        var.maintenance_config.maintenance_window.hour >= 0 &&
        var.maintenance_config.maintenance_window.hour <= 23 &&
        # Maintenance window update_track validation below
        try(var.maintenance_config.maintenance_window.update_track, null) == null ? true :
        contains(["canary", "stable"], var.maintenance_config.maintenance_window.update_track)
      )
    )
    error_message = "Maintenance window day must be between 1 and 7, maintenance window hour must be between 0 and 23 and maintenance window update_track must be 'stable' or 'canary'."
  }
}

variable "name" {
  description = "Name of the primary instance."
  type        = string
}

variable "network_config" {
  description = <<EOF
Network configuration for the instance. Only one between private_network and psc_config can be used.

(Optional) authorized_networks - Map of authorized networks. Name => CIDR block.
(Required) connectivity - Network connectivity configuration.
(Optional) connectivity.public_ipv4 - Whether to enable public IPv4 access.
(Optional) connectivity.psa_config - Private service access configuration.
(Optional) connectivity.psa_config.private_network - The private network to use.
(Optional) connectivity.psa_config.allocated_ip_range - The allocated IP range.
(Optional) connectivity.enable_private_path_for_services - Whether to enable private service access.
EOF
  type = object({
    authorized_networks = optional(map(string))
    connectivity = object({
      public_ipv4 = optional(bool, false)
      psa_config = optional(object({
        private_network    = string
        allocated_ip_range = optional(string)
      }))
      enable_private_path_for_services = optional(bool, false)
    })
  })
}

variable "password_validation_policy" {
  description = <<EOF
Password validation policy configuration for instances.

(Optional) enabled - Whether password validation is enabled.
(Optional) change_interval - Password change interval in seconds. Only supported for PostgreSQL.
(Optional) default_complexity - Whether to enforce default complexity.
(Optional) disallow_username_substring - Whether to disallow username substring.
(Optional) min_length - Minimum password length.
(Optional) reuse_interval - Password reuse interval.
EOF
  type = object({
    enabled = optional(bool, true)
    # change interval is only supported for postgresql
    change_interval             = optional(number)
    default_complexity          = optional(bool)
    disallow_username_substring = optional(bool)
    min_length                  = optional(number)
    reuse_interval              = optional(number)
  })
  default = null
}

variable "prefix" {
  description = "Optional prefix used to generate instance names."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty, please use null instead."
  }
}

variable "prevent_destroy" {
  description = "Prevent the main instance and any replicas from being destroyed."
  type        = bool
  default     = true
  nullable    = false
}

variable "project_id" {
  description = "The ID of the project where this instances will be created."
  type        = string
}

variable "region" {
  description = "Region of the primary instance."
  type        = string
}

variable "replicas" {
  description = <<EOF
Map of NAME => {REGION, KMS_KEY, AVAILABILITY_TYPE} for additional read replicas. Set to null to disable replica creation.

(Optional) additional_flags - Additional database flags specific to this replica.
(Optional) additional_labels - Additional labels specific to this replica.
(Optional) availability_type - The availability type for this replica.
(Optional) encryption_key_name - The encryption key name for this replica.
(Optional) machine_type - The machine type for this replica.
(Required) region - The region for this replica.
(Optional) network_config - Network configuration specific to this replica.
(Optional) network_config.authorized_networks - Map of authorized networks. Name => CIDR block.
(Optional) network_config.connectivity - Network connectivity configuration.
(Optional) network_config.connectivity.public_ipv4 - Whether to enable public IPv4 access.
(Optional) network_config.connectivity.psa_config - Private service access configuration.
(Optional) network_config.connectivity.psa_config.private_network - The private network to use.
(Optional) network_config.connectivity.psa_config.allocated_ip_range - The allocated IP range.
(Optional) network_config.connectivity.enable_private_path_for_services - Whether to enable private service access.
EOF
  type = map(object({
    additional_flags    = optional(map(string))
    additional_labels   = optional(map(string))
    availability_type   = optional(string)
    encryption_key_name = optional(string)
    machine_type        = optional(string)
    region              = string
    network_config = optional(object({
      authorized_networks = optional(map(string))
      connectivity = object({
        public_ipv4 = optional(bool, false)
        psa_config = optional(object({
          private_network    = string
          allocated_ip_range = optional(string)
        }))
        enable_private_path_for_services = optional(bool, false)
      })
    }), null)
  }))
  default  = {}
  nullable = false
}

variable "root_password" {
  description = <<EOF
Root password of the Cloud SQL instance, or flag to create a random password. Required for MS SQL Server.

(Optional) password - The root password. Leave empty to generate a random password.
(Optional) random_password - Whether to generate a random password.
EOF
  type = object({
    password        = optional(string)
    random_password = optional(bool, false)
  })
  default  = {}
  nullable = false
  validation {
    condition     = !(var.root_password.password != null && var.root_password.random_password)
    error_message = "Cannot provide root_password.password and root_password.random_password at the same time"
  }
}

variable "ssl" {
  description = <<EOF
Setting to enable SSL, set config and certificates.

(Optional) client_certificates - List of client certificate names to create.
(Optional) mode - SSL mode. Can be ALLOW_UNENCRYPTED_AND_ENCRYPTED, ENCRYPTED_ONLY, or TRUSTED_CLIENT_CERTIFICATE_REQUIRED.
EOF
  type = object({
    client_certificates = optional(list(string))
    # More details @ https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#ssl_mode
    mode = optional(string)
  })
  default  = {}
  nullable = false
  validation {
    condition     = var.ssl.mode == null || contains(["ALLOW_UNENCRYPTED_AND_ENCRYPTED", "ENCRYPTED_ONLY", "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"], var.ssl.mode)
    error_message = "The variable mode can be ALLOW_UNENCRYPTED_AND_ENCRYPTED, ENCRYPTED_ONLY for all, or TRUSTED_CLIENT_CERTIFICATE_REQUIRED for PostgreSQL or MySQL."
  }
}

variable "time_zone" {
  description = "The time_zone to be used by the database engine (supported only for SQL Server), in SQL Server timezone format."
  type        = string
  default     = null
}

variable "users" {
  description = <<EOF
Map of users to create in the primary instance (and replicated to other replicas). For MySQL, anything after the first `@` (if present) will be used as the user's host. Set PASSWORD to null if you want to get an autogenerated password. The user types available are: 'BUILT_IN', 'CLOUD_IAM_USER' or 'CLOUD_IAM_SERVICE_ACCOUNT'.

(Optional) password - The user password. Leave empty to generate a random password.
(Optional) type - The user type. Must be one of BUILT_IN, CLOUD_IAM_USER, or CLOUD_IAM_SERVICE_ACCOUNT.
EOF
  type = map(object({
    password = optional(string)
    type     = optional(string, "BUILT_IN")
  }))
  default  = {}
  nullable = false
  validation {
    condition     = alltrue([for user in var.users : contains(["BUILT_IN", "CLOUD_IAM_USER", "CLOUD_IAM_SERVICE_ACCOUNT"], user.type)])
    error_message = "User type must be one of 'BUILT_IN', 'CLOUD_IAM_USER' or 'CLOUD_IAM_SERVICE_ACCOUNT'."
  }
}
