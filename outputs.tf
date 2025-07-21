locals {
  _all_instances = merge(
    { primary = google_sql_database_instance.primary },
    google_sql_database_instance.replicas
  )
}

output "client_certificates" {
  description = "The CA Certificate used to connect to the SQL Instance via SSL."
  value       = google_sql_ssl_cert.client_certificates
  sensitive   = true
}

output "connection_name" {
  description = "Connection name of the primary instance."
  value       = google_sql_database_instance.primary.connection_name
}

output "connection_names" {
  description = "Connection names of all instances."
  value = {
    for id, instance in local._all_instances :
    id => instance.connection_name
  }
}

output "dns_name" {
  description = "The dns name of the instance."
  value       = google_sql_database_instance.primary.dns_name
}

output "dns_names" {
  description = "Dns names of all instances."
  value = {
    for id, instance in local._all_instances :
    id => instance.dns_name
  }
}

output "id" {
  description = "Fully qualified primary instance id."
  value       = google_sql_database_instance.primary.id
}

output "ids" {
  description = "Fully qualified ids of all instances."
  value = {
    for id, instance in local._all_instances :
    id => instance.id
  }
}

output "ip" {
  description = "IP address of the primary instance."
  value       = google_sql_database_instance.primary.private_ip_address
}

output "ips" {
  description = "IP addresses of all instances."
  value = {
    for id, instance in local._all_instances :
    id => instance.private_ip_address
  }
}

output "name" {
  description = "Name of the primary instance."
  value       = google_sql_database_instance.primary.name
}

output "names" {
  description = "Names of all instances."
  value = {
    for id, instance in local._all_instances :
    id => instance.name
  }
}
