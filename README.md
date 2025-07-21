# terraform-google-cloudsql ![policy](https://github.com/kapetndev/terraform-google-cloudsql/workflows/policy/badge.svg)

Terraform module to create and manage Google Cloud Platform SQL database
resources.

## Usage

See the [examples](examples) directory for working examples for reference:

```hcl
module "my_database_instance" {
  source           = "git::https://github.com/kapetndev/terraform-google-cloudsql.git?ref=v0.1.0
  collation        = "en_US.UTF-8"
  database_version = "POSTGRES_17"
  machine_type     = "db-f1-micro"
  name             = "my-database-instance"
  region           = "europe-west2"
  
  databases = [
    "my_database",
  ]

  network_config = {
    connectivity = {
      ipv4_enabled = true
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| [google](https://registry.terraform.io/providers/hashicorp/google/latest) | >= 5.6.0 |
| [random](https://registry.terraform.io/providers/hashicorp/random/latest) | >= 3.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [`random_password.passwords`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [`random_password.root_password`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [`random_id.database_id`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [`google_sql_database_instance.primary`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [`google_sql_database_instance.replicas[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [`google_sql_database.databases[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [`google_sql_ssl_cert.client_certificates[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_ssl_cert) | resource |
| [`google_sql_user.users[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `database_version` | The database type and version to create | `string` | | yes |
| `machine_type` | The machine type to create for the primary instnace | `string` | | yes |
| `name` | Name of the primary instance | `string` | | yes |
| `network_config` | The network configuration for the primary instance | `object{...}` | | yes |
| `network_config.connectivity` | Network connectivity configuration | `object{...}` | | yes |
| `network_config.connectivity.enable_private_path_for_services` | Whether to enable private service access | `bool` | `false` | no |
| `network_config.connectivity.public_ipv4` | Whether to enable public IPv4 access | `bool` | `false` | no |
| `network_config.connectivity.psa_config` | Private service access configuration | `object{...}` | `null` | no |
| `network_config.connectivity.psa_config.private_network` | The private network to use | `string` | | yes |
| `network_config.connectivity.psa_config.allocated_ip_range` | The allocated IP range for private service access | `string` | `null` | no |
| `network_config.authorized_networks` | A map of authorized networks. Name => CIDR block | `map(string)` | `{}` | no |
| `region` | Region the primary instance will sit in | `string` | | yes |
| `activation_policy` | Specifies when the instance should be active. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`. Default is `ALWAYS` | `string` | `"ALWAYS"` | no |
| `availability_type` | The availability type for the primary replica. Either `ZONAL` or `REGIONAL`. Default is `ZONAL` | `string` | `"ZONAL"` | no |
| `backup_configuration` | The backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas | `object{...}` | `{}` | no |
| `backup_configuration.enabled` | Whether backups are enabled | `bool` | `false` | no |
| `backup_configuration.binary_log_enabled` | Whether binary logging is enabled | `bool` | `false` | no |
| `backup_configuration.location` | The location of the backup | `string` | `null` | no |
| `backup_configuration.log_retention_days` | The number of days to retain transaction log files | `number` | `7` | no |
| `backup_configuration.point_in_time_recovery_enabled` | Whether point in time recovery is enabled | `bool` | `null` | no |
| `backup_configuration.retention_count` | The number of backups to retain | `number` | `7` | no |
| `backup_configuration.start_time` | The start time for the backup window, in 24 hour format. The time must be in the format "HH:MM" and must be in UTC | `string` | `"23:00"` | no |
| `collation` | The collation for the primary instance. Only used for MySQL and PostgreSQL | `string` | `null` | no |
| `connector_enforcement` | Specifies if connections must use Cloud SQL connectors | `string` | `null` | no |
| `data_cache` | Specifies if the data cache should be enabled. Only used for MYSQL and PostgreSQL | `bool` | `false` | no |
| `databases` | A list of databases to create once the primary instance is created | `set(string)` | `[]` | no |
| `descriptive_name` | The authoritative name of the primary instance. Used instead of `name` variable | `string` | `null` | no |
| `disk_autoresize_limit` | The maximum size to which storage capacity can be automatically increased. Default is 0, which specifies that there is no limit | `number` | `0` | no |
| `disk_size` | The size of the disk attached to the primary instance, specified in GB. Set to null to enable autoresize | `number` | `null` | no |
| `disk_type` | The type of data disk: `PD_SSD` or `PD_HDD`. Default is `PD_SSD` | `string` | `"PD_SSD"` | no |
| `edition` | The edition of the primary instance, can be ENTERPRISE or ENTERPRISE_PLUS. Default is ENTERPRISE | `string` | `"ENTERPRISE"` | no |
| `encryption_key_name` | The full path to the encryption key used for the CMEK disk encryption of the primary instance | `string` | `null` | no |
| `flags` | A map of key/value database flag pairs for database-specific tuning | `map(string)` | `{}` | no |
| `insights_config` | The Query Insights configuration. Default is to disable Query Insights | `object{...}` | `null` | no |
| `insights_config.query_plans_per_minute` | The number of query plans to generate per minute | `number` | `5` | no |
| `insights_config.query_string_length` | The maximum query string length. Default is 1024 characters. Default is 1024 characters | `number` | `1024` | no |
| `insights_config.record_application_tags` | Whether to record application tags | `bool` | `false` | no |
| `insights_config.record_client_address` | Whether to record client addresses | `bool` | `false` | no |
| `labels` | A map of user defined key/value label pairs to assign to the primary instance | `map(string)` | `{}` | no |
| `location_preference` | The location preference for the primary instance. Useful for regional instances | `object{...}` | `null` | no |
| `location_preference.zone` | The preferred zone for the instance | `string` | `null` | no |
| `location_preference.secondary_zone` | List of secondary zones for the instance | `string` | `null` | no |
| `maintenance_config` | The maintenance window configuration and maintenance deny period (up to 90 days). Date format: 'yyyy-mm-dd' | `object{...}` | `{}` | no |
| `maintenance_config.maintenance_window` | The maintenance window configuration | `object{...}` | `null` | no |
| `maintenance_config.maintenance_window.day` | Day of week (1-7), starting with Monday | `number` | | yes |
| `maintenance_config.maintenance_window.hour` | Hour of day (0-23) | `number` | | yes |
| `maintenance_config.maintenance_window.update_track` | The update track. Either 'canary' or 'stable' | `string` | `null` | no |
| `maintenance_config.deny_maintenance_period` | The maintenance deny period | `object{...}` | `null` | no |
| `maintenance_config.deny_maintenance_period.end_date` | The end date in YYYY-MM-DD format | `string` | | yes |
| `maintenance_config.deny_maintenance_period.start_date` | The start date in YYYY-MM-DD format | `string` | | yes |
| `maintenance_config.deny_maintenance_period.start_time` | The start time in HH:MM:SS format | `string` | `"00:00:00"` | no |
| `password_validation_policy` | The password validation policy configuration for the primary instances | `object{...}` | `null` | no |
| `password_validation_policy.change_interval` | Password change interval in seconds. Only supported for PostgreSQL | `number` | `null` | no |
| `password_validation_policy.default_complexity` | Whether to enforce default complexity | `bool` | `null` | no |
| `password_validation_policy.disallow_username_substring` | Whether to disallow username substring | `bool` | `null` | no |
| `password_validation_policy.min_length` | Minimum password length | `number` | `null` | no |
| `password_validation_policy.reuse_interval` | Password reuse interval | `number` | `null` | no |
| `prefix` | An optional prefix used to generate the primary instance name | `string` | `null` | no |
| `prevent_destroy` | Prevent the primary instance and any replicas from being destroyed | `bool` | `true` | no |
| `project_id` | The ID of the project in which the resource belongs. If it is not provided, the provider project is used | `string` | `null` | no |
| `replicas` | A map of replicas to create for the primary instance, where the key is the replica name to be apended to the primary instance name | `map(object{...})` | `{}` | no |
| `replicas[*].additional_flags` | Additional database flags specific to this replica | `map(string)` | `null` | no |
| `replicas[*].additional_labels` | Additional labels specific to this replica | `map(string)` | `null` | no |
| `replicas[*].availability_type` | The availability type for this replica | `string` | `null` | no |
| `replicas[*].encryption_key_name` | The encryption key name for this replica | `string` | `null` | no |
| `replicas[*].machine_type` | The machine type for this replica | `string` | `null` | no |
| `replicas[*].region` | The region for this replica | `string` | `null` | no |
| `replicas[*].network_config` | Network configuration specific to this replica | `object{...}` | `null` | no |
| `replicas[*].network_config.connectivity` | Network connectivity configuration | `object{...}` | | yes |
| `replicas[*].network_config.connectivity.enable_private_path_for_services` | Whether to enable private service access | `bool` | `false` | no |
| `replicas[*].network_config.connectivity.public_ipv4` | Whether to enable public IPv4 access | `bool` | `false` | no |
| `replicas[*].network_config.connectivity.psa_config` | Private service access configuration | `object{...}` | `null` | no |
| `replicas[*].network_config.connectivity.psa_config.private_network` | The private network to use | `string` | | yes |
| `replicas[*].network_config.connectivity.psa_config.allocated_ip_range` | The allocated IP range | `string` | `null` | no |
| `replicas[*].network_config.authorized_networks` | Map of authorized networks. Name => CIDR block | `map(string)` | `null` | no |
| `root_password` | Root password of the Cloud SQL instance, or flag to create a random password. Required for MS SQL Server | `object{...}` | `{}` | no |
| `root_password.password` | The root password. Leave empty to generate a random password | `string` | `null` | no |
| `root_password.random_password` | Whether to generate a random password | `bool` | `false` | no |
| `ssl` | Setting to enable SSL, set config and certificates | `object{...}` | `{}` | no |
| `ssl.client_certificates` | List of client certificate names to create | `set(string)` | `[]` | no |
| `ssl.mode` | SSL mode. Can be ALLOW_UNENCRYPTED_AND_ENCRYPTED, ENCRYPTED_ONLY, or TRUSTED_CLIENT_CERTIFICATE_REQUIRED | `string` | `"ALLOW_UNENCRYPTED_AND_ENCRYPTED"` | no |
| `time_zone` | The time_zone to be used by the database engine (supported only for SQL Server), in SQL Server timezone format | `string` | `null` | no |
| `users` | A map of users to create in the primary instance. For MySQL, anything after the first `@` (if present) will be used as the user's host. Set PASSWORD to null if you want to get an autogenerated password. The user types available are: `BUILT_IN`, `CLOUD_IAM_USER` or `CLOUD_IAM_SERVICE_ACCOUNT` | `map(object{...})` | `{}` | no |
| `users[*].password` | The user password. Leave empty to generate a random password | `string` | `null` | no |
| `users[*].type` | The user type. Must be one of BUILT_IN, CLOUD_IAM_USER, or CLOUD_IAM_SERVICE_ACCOUNT | `string` | `"BUILT_IN"` | no |

## Outputs

| Name | Description |
|------|-------------|
| `client_certificates` | The client SSL certificates for the primary instance |
| `connection_name` | The connection name of the primary instance |
| `connection_names` | The connection names of all instances, including replicas |
| `dns_name` | The DNS name of the primary instance |
| `dns_names` | The DNS names of all instances, including replicas |
| `id` | The ID of the primary instance |
| `ids` | The IDs of all instances, including replicas |
| `ip` | The IP address of the primary instance |
| `ips` | The IP addresses of all instances, including replicas |
| `name` | The name of the primary instance |
| `names` | The names of all instances, including replicas |
