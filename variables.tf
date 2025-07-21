variable "activation_policy" {
  description = "Specifies when the instance should be active. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`. Default is `ALWAYS`."
  type        = string
  default     = "ALWAYS"
  nullable    = false
  validation {
    condition     = contains(["NEVER", "ON_DEMAND", "ALWAYS"], var.activation_policy)
    error_message = "The variable activation_policy must be ALWAYS, NEVER or ON_DEMAND."
  }
}

variable "availability_type" {
  description = "The availability type for the primary replica. Either `ZONAL` or `REGIONAL`. Default is `ZONAL`."
  type        = string
  default     = "ZONAL"
  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "The variable availability_type must be ZONAL or REGIONAL."
  }
}

variable "backup_configuration" {
  description = <<EOF
The backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas.

(Optional) enabled - Whether backups are enabled. Default is false.
(Optional) binary_log_enabled - Whether binary logging is enabled. Default is false.
(Optional) location - The location of the backup.
(Optional) log_retention_days - The number of days to retain transaction log files. Default is 7.
(Optional) point_in_time_recovery_enabled - Whether point in time recovery is enabled.
(Optional) retention_count - The number of backups to retain. Default is 7.
(Optional) start_time - The start time for the backup window, in 24 hour format. Default is "23:00". The time must be in the format "HH:MM" and must be in UTC.
EOF
  type = object({
    enabled                        = optional(bool, false)
    binary_log_enabled             = optional(bool, false)
    location                       = optional(string)
    log_retention_days             = optional(number, 7)
    point_in_time_recovery_enabled = optional(bool)
    retention_count                = optional(number, 7)
    start_time                     = optional(string, "23:00")
  })
  default = {
    binary_log_enabled             = false
    enabled                        = false
    location                       = null
    log_retention_days             = 7
    point_in_time_recovery_enabled = null
    retention_count                = 7
    start_time                     = "23:00"
  }
  nullable = false
}

variable "connector_enforcement" {
  description = "Specifies if connections must use Cloud SQL connectors."
  type        = string
  default     = null
}

variable "data_cache" {
  description = "Specifies if the data cache should be enabled. Only used for MYSQL and PostgreSQL."
  type        = bool
  default     = false
  nullable    = false
}

variable "database_version" {
  description = "The database type and version to create."
  type        = string
}

variable "databases" {
  description = <<EOF
A list of databases to create once the primary instance is created.

(Required) name - A unique name for the database.

(Optional) charset - The character set for the database. Default is UTF8 for MySQL and PostgreSQL, and SQL_Latin1_General_CP1_CI_AS for SQL Server.
(Optional) collation - The collation for the database. Default is en_US.UTF8 for MySQL and PostgreSQL, and SQL_Latin1_General_CP1_CI_AS for SQL Server.
EOF
  type = list(object({
    charset   = optional(string)
    collation = optional(string)
    name      = string
  }))
  default = []
}

variable "descriptive_name" {
  description = "The authoritative name of the primary instance. Used instead of `name` variable."
  type        = string
  default     = null
}

variable "disk_autoresize_limit" {
  description = "The maximum size to which storage capacity can be automatically increased. Default is 0, which specifies that there is no limit."
  type        = number
  default     = 0
}

variable "disk_size" {
  description = "The size of the disk attached to the primary instance, specified in GB. Set to null to enable autoresize."
  type        = number
  default     = null
}

variable "disk_type" {
  description = "The type of data disk: `PD_SSD` or `PD_HDD`. Default is `PD_SSD`."
  type        = string
  default     = "PD_SSD"
  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.disk_type)
    error_message = "The variable disk_type must be PD_SSD or PD_HDD."
  }
}

variable "edition" {
  description = "The edition of the primary instance, can be ENTERPRISE or ENTERPRISE_PLUS. Default is ENTERPRISE."
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
  description = "A map of key/value database flag pairs for database-specific tuning."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "insights_config" {
  description = <<EOF
The Query Insights configuration. Default is to disable Query Insights.

(Optional) query_plans_per_minute - The number of query plans to generate per minute. Default is 5.
(Optional) query_string_length - The maximum query string length. Default is 1024 characters. Default is 1024 characters.
(Optional) record_application_tags - Whether to record application tags. Default is false.
(Optional) record_client_address - Whether to record client addresses. Default is false.
EOF
  type = object({
    query_plans_per_minute  = optional(number, 5)
    query_string_length     = optional(number, 1024)
    record_application_tags = optional(bool, false)
    record_client_address   = optional(bool, false)
  })
  default = null
}

variable "labels" {
  description = "A map of user defined key/value label pairs to assign to the primary instance."
  type        = map(string)
  default     = {}
}

variable "location_preference" {
  description = <<EOF
The location preference for the primary instance. Useful for regional instances.

(Optional) zone - The preferred zone for the instance.
(Optional) secondary_zones - List of secondary zones for the instance.
EOF
  type = object({
    zone           = string
    secondary_zone = optional(string)
  })
  default = null
}

variable "machine_type" {
  description = "The machine type to create for the primary instnace."
  type        = string
}

variable "maintenance_config" {
  description = <<EOF
The maintenance window configuration and maintenance deny period (up to 90 days). Date format: 'yyyy-mm-dd'.

(Optional) maintenance_window - The maintenance window configuration.
(Optional) maintenance_window.day - Day of week (1-7), starting with Monday.
(Optional) maintenance_window.hour - Hour of day (0-23).
(Optional) maintenance_window.update_track - The update track. Either 'canary' or 'stable'.
(Optional) deny_maintenance_period - The maintenance deny period.
(Optional) deny_maintenance_period.end_date - The end date in YYYY-MM-DD format.
(Optional) deny_maintenance_period.start_date - The start date in YYYY-MM-DD format.
(Optional) deny_maintenance_period.start_time - The start time in HH:MM:SS format. Default is "00:00:00".
EOF
  type = object({
    maintenance_window = optional(object({
      day          = number
      hour         = number
      update_track = optional(string, null)
    }), null)
    deny_maintenance_period = optional(object({
      end_date   = string
      start_date = string
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
The network configuration for the primary instance.

(Required) connectivity - The network connectivity configuration.
(Optional) connectivity.enable_private_path_for_services - Whether to enable private service access. Default is false.
(Optional) connectivity.psa_config - The private service access configuration.
(Required) connectivity.psa_config.private_network - The private network to use.
(Optional) connectivity.psa_config.allocated_ip_range - The allocated IP range for private service access.
(Optional) connectivity.public_ipv4 - Whether to enable public IPv4 access.

(Optional) authorized_networks - A map of authorized networks. Name => CIDR block.
EOF
  type = object({
    authorized_networks = optional(map(string), {})
    connectivity = object({
      enable_private_path_for_services = optional(bool, false)
      public_ipv4                      = optional(bool, false)
      psa_config = optional(object({
        private_network    = string
        allocated_ip_range = optional(string)
      }))
    })
  })
}

variable "password_validation_policy" {
  description = <<EOF
The password validation policy configuration for the primary instances.

(Optional) change_interval - Password change interval in seconds. Only supported for PostgreSQL.
(Optional) default_complexity - Whether to enforce default complexity.
(Optional) disallow_username_substring - Whether to disallow username substring.
(Optional) min_length - Minimum password length.
(Optional) reuse_interval - Password reuse interval.
EOF
  type = object({
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
  description = "An optional prefix used to generate the primary instance name."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty, please use null instead."
  }
}

variable "prevent_destroy" {
  description = "Prevent the primary instance and any replicas from being destroyed."
  type        = bool
  default     = true
  nullable    = false
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "region" {
  description = "Region the primary instance will sit in."
  type        = string
}

variable "replicas" {
  description = <<EOF
A map of replicas to create for the primary instance, where the key is the replica name to be apended to the primary instance name.

(Optional) additional_flags - Additional database flags specific to this replica. These will be merged with the primary instance flags.
(Optional) additional_labels - Additional labels specific to this replica. These will be merged with the primary instance labels.
(Optional) availability_type - The availability type for this replica. If not specified, it will inherit the primary instance availability type.
(Optional) encryption_key_name - The encryption key name for this replica.
(Optional) machine_type - The machine type for this replica. If not specified, it will inherit the primary instance machine type.
(Optional) region - The region for this replica. If not specified, it will inherit the primary instance region.
(Optional) network_config - Network configuration specific to this replica. If not specified, it will inherit the primary instance network configuration.
(Optional) network_config.authorized_networks - Map of authorized networks. Name => CIDR block.
(Optional) network_config.connectivity - Network connectivity configuration.
(Optional) network_config.connectivity.enable_private_path_for_services - Whether to enable private service access.
(Optional) network_config.connectivity.public_ipv4 - Whether to enable public IPv4 access.
EOF
  type = map(object({
    additional_flags    = optional(map(string))
    additional_labels   = optional(map(string))
    availability_type   = optional(string)
    encryption_key_name = optional(string)
    machine_type        = optional(string)
    region              = optional(string)
    network_config = optional(object({
      authorized_networks = optional(map(string))
      connectivity = optional(object({
        enable_private_path_for_services = optional(bool)
        public_ipv4                      = optional(bool)
      }))
    }), null)
  }))
  default  = {}
  nullable = false
}

variable "root_password" {
  description = <<EOF
The root password of the Cloud SQL instance, or flag to create a random password. Required for MS SQL Server.

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
The SSL configuration for the primary instance.

(Optional) client_certificates - List of client certificate names to create.
(Optional) mode - SSL mode. Can be ALLOW_UNENCRYPTED_AND_ENCRYPTED, ENCRYPTED_ONLY, or TRUSTED_CLIENT_CERTIFICATE_REQUIRED.
EOF
  type = object({
    client_certificates = optional(set(string), [])
    # More details @ https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#ssl_mode
    mode = optional(string, "ALLOW_UNENCRYPTED_AND_ENCRYPTED")
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
A map of users to create in the primary instance. For MySQL, anything after the first `@` (if present) will be used as the user's host. Set PASSWORD to null if you want to get an autogenerated password. The user types available are: `BUILT_IN`, `CLOUD_IAM_USER` or `CLOUD_IAM_SERVICE_ACCOUNT`.

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
