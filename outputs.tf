output "project_id" {
  value = var.project_id
}

output "name" {
  description = "The name for Cloud SQL instance"
  value       = module.pg.instance_name
}

output "authorized_network" {
  value = var.ip_configuration.authorized_networks
}

output "replicas" {
  value     = module.pg.replicas
  sensitive = true
}

output "instances" {
  value     = module.pg.instances
  sensitive = true
}