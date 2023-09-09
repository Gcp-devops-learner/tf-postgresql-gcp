# Copyright 2022 Google LLC. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreement with Google.

 
locals {
  databases = { for db in var.additional_databases : db.name => db }
  users     = { for u in var.additional_users : u.name => u }

  retained_backups = lookup(var.backup_configuration, "retained_backups", null)
  retention_unit   = lookup(var.backup_configuration, "retention_unit", null)
  mandatory_db_flags = [{ name = "log_checkpoints", value = "on" },
      { name = "log_error_verbosity", value = "default" },
      { name = "log_connections", value = "on" },
      { name = "log_disconnections", value = "on" },
      { name = "log_duration", value = "on" },
      { name = "log_lock_waits", value = "on" },
      { name = "log_statement", value = "all" },
      { name = "log_hostname", value = "on" },
      { name = "log_parser_stats", value = "off" },
      { name = "log_planner_stats", value = "off" },
      { name = "log_executor_stats", value = "off" },
      { name = "log_statement_stats", value = "off" },
      { name = "log_min_messages", value = "log" },
      { name = "log_min_error_statement", value = "error" },
      { name = "log_temp_files", value = "0" },
      { name = "log_min_duration_statement", value = "-1" }
    ]
}

####################################
# Database Instance configurations #
####################################

resource "google_sql_database_instance" "default" {
  provider            = google-beta
  project             = var.project_id
  name                = "${var.aexp_app_env}-${var.aexp_app_name}-${var.aexp_app_carid}-${var.name}"
  database_version    = var.database_version
  region              = var.region
  encryption_key_name = var.encryption_key_name
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    activation_policy = var.activation_policy
    availability_type = var.availability_type
    dynamic "database_flags" {
      for_each = local.mandatory_db_flags
      content {
        name  = lookup(database_flags.value, "name", null)
        value = lookup(database_flags.value, "value", null)
      }
    }
    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = lookup(database_flags.value, "name", null)
        value = lookup(database_flags.value, "value", null)
      }
    }

    dynamic "backup_configuration" {
      for_each = [var.backup_configuration]
      content {
        binary_log_enabled             = false
        enabled                        = lookup(backup_configuration.value, "enabled", null)
        start_time                     = lookup(backup_configuration.value, "start_time", null)
        location                       = lookup(backup_configuration.value, "location", null)
        point_in_time_recovery_enabled = lookup(backup_configuration.value, "point_in_time_recovery_enabled", false)
        transaction_log_retention_days = lookup(backup_configuration.value, "transaction_log_retention_days", null)

        dynamic "backup_retention_settings" {
          for_each = local.retained_backups != null || local.retention_unit != null ? [var.backup_configuration] : []
          content {
            retained_backups = local.retained_backups
            retention_unit   = local.retention_unit
          }
        }
      }
    }
    dynamic "ip_configuration" {
      for_each = [var.ip_configuration]
      content {
        ipv4_enabled       = lookup(ip_configuration.value, "ipv4_enabled", null)
        private_network    = lookup(ip_configuration.value, "private_network", null)
        require_ssl        = lookup(ip_configuration.value, "require_ssl", null)
        allocated_ip_range = lookup(ip_configuration.value, "allocated_ip_range", null)

        dynamic "authorized_networks" {
          for_each = lookup(ip_configuration.value, "authorized_networks", [])
          content {
            expiration_time = lookup(authorized_networks.value, "expiration_time", null)
            name            = lookup(authorized_networks.value, "name", null)
            value           = lookup(authorized_networks.value, "value", null)
          }
        }
      }
    }
    dynamic "insights_config" {
      for_each = var.insights_config != null ? [var.insights_config] : []

      content {
        query_insights_enabled  = true
        query_string_length     = lookup(insights_config.value, "query_string_length", 1024)
        record_application_tags = lookup(insights_config.value, "record_application_tags", false)
        record_client_address   = lookup(insights_config.value, "record_client_address", false)
      }
    }

    disk_autoresize       = var.disk_autoresize
    disk_autoresize_limit = var.disk_autoresize_limit
    disk_size             = var.disk_size
    disk_type             = var.disk_type
    pricing_plan          = var.pricing_plan
    
    
    user_labels = merge({
      "aexp_account_type" = var.aexp_account_type
      "aexp_app_carid" = var.aexp_app_carid
      "aexp_app_env" = var.aexp_app_env
      "aexp_app_name" = var.aexp_app_name
      "aexp_app_supportgroup" = var.aexp_app_supportgroup
      "aexp_app_tier" = var.aexp_app_tier
      "aexp_data_classification" = var.aexp_data_classification
      "aexp_data_sensitivity" = var.aexp_data_sensitivity
      "aexp_ops_supportgroup" = var.aexp_ops_supportgroup
      "aexp_provisioner_carid" = var.aexp_provisioner_carid
      "aexp_provisioner_repo" = var.aexp_provisioner_repo
      "aexp_provisioner_workspace" = var.aexp_provisioner_workspace
    }, var.user_labels)
    

    location_preference {
      zone = var.zone
    }

    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = var.maintenance_window_update_track
    }
  }

  timeouts {
      create = var.create_timeout
      update = var.update_timeout
      delete = var.delete_timeout
    }
  
}
/*
resource "google_sql_database" "default" {
  count      = var.enable_default_db ? 1 : 0
  name       = var.db_name
  project    = var.project_id
  instance   = google_sql_database_instance.default.name
  charset    = var.db_charset
  collation  = var.db_collation
  depends_on = [google_sql_database_instance.default]
}

resource "google_sql_database" "additional_databases" {
  for_each   = local.databases
  project    = var.project_id
  name       = each.value.name
  charset    = lookup(each.value, "charset", null)
  collation  = lookup(each.value, "collation", null)
  instance   = google_sql_database_instance.default.name
  depends_on = [google_sql_database_instance.default]
}


resource "random_id" "user-password" {
  keepers = {
    name = google_sql_database_instance.default.name
  }

  byte_length = 8
  depends_on  = [google_sql_database_instance.default]
}

resource "random_id" "additional_passwords" {
  for_each = local.users
  keepers = {
    name = google_sql_database_instance.default.name
  }
  byte_length = 8
  depends_on  = [google_sql_database_instance.default]
}

###########################
# SQL User configurations #
###########################

resource "google_sql_user" "default" {
  count    = var.enable_default_user ? 1 : 0
  name     = var.user_name
  project  = var.project_id
  instance = google_sql_database_instance.default.name
  password = var.user_password == "" ? random_id.user-password.hex : var.user_password
  depends_on = [
    google_sql_database_instance.default,
    google_sql_database_instance.replicas,
  ]
}

resource "google_sql_user" "additional_users" {
  for_each = local.users
  project  = var.project_id
  name     = each.value.name
  password = coalesce(each.value["password"], random_id.additional_passwords[each.value.name].hex)
  instance = google_sql_database_instance.default.name
  depends_on = [
    google_sql_database_instance.default,
    google_sql_database_instance.replicas,
  ]
}
*/