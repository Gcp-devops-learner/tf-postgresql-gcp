/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#**********************************
#  Common                         
#**********************************

variable "project_id" {
  type        = string
  description = "The project to run tests against"
  default     = ""
}

variable "pg_ha_name" {
  type        = string
  description = "The name for Cloud SQL instance"
  default     = ""
}

variable "random_instance_name" {
  type        = bool
  description = "Sets random suffix at the end of the Cloud SQL resource name"
  default     = false
}

// required
variable "database_version" {
  description = "(Required) The database version to use."
  type        = string
  default     = "POSTGRES_13"

  validation {
    condition     = contains(["POSTGRES_9_6", "POSTGRES_10", "POSTGRES_11", "POSTGRES_12", "POSTGRES_13", "POSTGRES_14"], var.database_version)
    error_message = "The value must only be one of these valid values: POSTGRES_9_6, POSTGRES_10, POSTGRES_11, POSTGRES_12, POSTGRES_13, POSTGRES_14."
  }
}

variable "region" {
  type        = string
  description = "The region of the Cloud SQL resources"
  default     = ""
}

#**********************************
# Master Configurations
#**********************************

variable "tier" {
  type        = string
  description = "The project to run tests against"
  default     = ""
}

variable "zone" {
  type        = string
  description = "The project to run tests against"
  default     = ""
}

variable "availability_type" {
  type        = string
  description = "The project to run tests against"
  default     = ""
}

variable "maintenance_window_day" {
  type        = string
  description = "The project to run tests against"
  default     = ""
}

variable "maintenance_window_hour" {
  type        = string
  description = "The project to run tests against"
  default     = ""
}

variable "maintenance_window_update_track" {
  type        = string
  description = "The project to run tests against"
  default     = ""
}

variable "deletion_protection" {
  type        = string
  description = "The project to run tests against"
  default     = ""
}

variable "db_charset" {
  type        = string
  description = "The name for Cloud SQL db char set"
  default     = ""
}

variable "db_collation" {
  type        = string
  description = "The name for Cloud SQL instance db collection value"
  default     = ""
}

variable "user_name" {
  type        = string
  description = "The name for Cloud SQL user name"
  default     = ""
}

variable "user_password" {
  type        = string
  description = "The name for Cloud SQL user name password"
  default     = ""
}

variable "ip_configuration" {
  description = "The ip configuration for the master instances."
  type = object({
    authorized_networks = list(map(string))
    ipv4_enabled        = bool
    private_network     = string
    require_ssl         = bool
    allocated_ip_range  = string
  })
  default = {
    authorized_networks = []
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = null
    allocated_ip_range  = null
  }
}

variable "backup_configuration" {
  description = "The backup_configuration settings subblock for the database setings"
  type = object({
    enabled                        = bool
    start_time                     = string
    location                       = string
    point_in_time_recovery_enabled = bool
    transaction_log_retention_days = string
    retained_backups               = number
    retention_unit                 = string
  })
}

variable "database_flags" {
  description = "The database flags for the master instance. See [more details](https://cloud.google.com/sql/docs/postgres/flags)"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "user_labels" {
  description = "The key/value labels for the master instances."
  type        = map(string)
  default     = {}
}

#**********************************
# Read Replica Configurations 
#**********************************

variable "read_replicas" {
  description = "List of read replicas to create. Encryption key is required for replica in different region. For replica in same region as master set encryption_key_name = null"
  type = list(object({
    name                  = string
    tier                  = string
    zone                  = string
    disk_type             = string
    disk_autoresize       = bool
    disk_autoresize_limit = number
    disk_size             = string
    user_labels           = map(string)
    database_flags = list(object({
      name  = string
      value = string
    }))
    ip_configuration = object({
      authorized_networks = list(map(string))
      ipv4_enabled        = bool
      private_network     = string
      require_ssl         = bool
      allocated_ip_range  = string
    })
    encryption_key_name = string
  }))
  default = []
}

variable "additional_databases" {
  description = "A list of databases to be created in your cluster"
  type = list(object({
    name      = string
    charset   = string
    collation = string
  }))
  default = []
}

variable "additional_users" {
  description = "A list of users to be created in your cluster"
  type = list(object({
    name     = string
    password = string
  }))
  default = []
}