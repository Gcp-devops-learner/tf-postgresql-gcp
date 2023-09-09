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

variable "project_id" {
  type        = string
  description = "The project ID to manage the Cloud SQL resources"
  default     = ""
}

variable "name" {
  type        = string
  description = "The name of the Cloud SQL resources"
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

// required
variable "region" {
  type        = string
  description = "The region of the Cloud SQL resources"
  default     = ""
}

variable "tier" {
  description = "The tier for the master instance."
  type        = string
  default     = ""
}

variable "zone" {
  type        = string
  description = "The zone for the master instance, it should be something like: `us-central1-a`, `us-east1-c`."
  default     = ""
}

variable "activation_policy" {
  description = "The activation policy for the master instance.Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  type        = string
  default     = "ALWAYS"
}

variable "availability_type" {
  description = "The availability type for the master instance.This is only used to set up high availability for the PostgreSQL instance. Can be either `ZONAL` or `REGIONAL`."
  type        = string
  default     = ""
}

variable "disk_autoresize" {
  description = "Configuration to increase storage size."
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "The maximum size to which storage can be auto increased."
  type        = number
  default     = 0
}

variable "disk_size" {
  description = "The disk size for the master instance."
  default     = 10
}

variable "disk_type" {
  description = "The disk type for the master instance."
  type        = string
  default     = "PD_SSD"
}

variable "pricing_plan" {
  description = "The pricing plan for the master instance."
  type        = string
  default     = "PER_USE"
}

variable "maintenance_window_day" {
  description = "The day of week (1-7) for the master instance maintenance."
  type        = number
  default     = 1
}

variable "maintenance_window_hour" {
  description = "The hour of day (0-23) maintenance window for the master instance maintenance."
  type        = number
  default     = 23
}

variable "maintenance_window_update_track" {
  description = "The update track of maintenance window for the master instance maintenance.Can be either `canary` or `stable`."
  type        = string
  default     = "canary"
}

variable "database_flags" {
  description = "The database flags for the master instance. See [more details](https://cloud.google.com/sql/docs/postgres/flags)"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
      { name = "log_checkpoints", value = "on" },
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

variable "user_labels" {
  description = "The key/value labels for the master instances."
  type        = map(string)
  default     = {}
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
  default = {
    enabled                        = false
    start_time                     = null
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = null
    retention_unit                 = null
  }
}

variable "insights_config" {
  description = "The insights_config settings for the database."
  type = object({
    query_string_length     = number
    record_application_tags = bool
    record_client_address   = bool
  })
  default = null
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

// Read Replicas

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

variable "read_replica_name_suffix" {
  description = "The optional suffix to add to the read instance name"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "The name of the default database to create"
  type        = string
  default     = "default"
}

variable "db_charset" {
  description = "The charset for the default database"
  type        = string
  default     = ""
}

variable "db_collation" {
  description = "The collation for the default database. Example: 'en_US.UTF8'"
  type        = string
  default     = ""
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

variable "user_name" {
  description = "The name of the default user"
  type        = string
  default     = "default"
}

variable "user_password" {
  description = "The password for the default user. If not set, a random one will be generated and available in the generated_user_password output variable."
  type        = string
  default     = ""


}

variable "additional_users" {
  description = "A list of users to be created in your cluster"
  type = list(object({
    name     = string
    password = string
  }))
  default = []
}
/*
variable "iam_user_emails" {
  description = "A list of IAM users to be created in your cluster"
  type        = list(string)
  default     = []
}
*/

variable "create_timeout" {
  description = "The optional timout that is applied to limit long database creates."
  type        = string
  default     = "15m"
}

variable "update_timeout" {
  description = "The optional timout that is applied to limit long database updates."
  type        = string
  default     = "15m"
}

variable "delete_timeout" {
  description = "The optional timout that is applied to limit long database deletes."
  type        = string
  default     = "15m"
}

variable "encryption_key_name" {
  description = "The full path to the encryption key used for the CMEK disk encryption"
  type        = string
  default     = null
}

variable "module_depends_on" {
  description = "List of modules or resources this module depends on."
  type        = list(any)
  default     = []
}

variable "deletion_protection" {
  description = "Used to block Terraform from deleting a SQL Instance."
  type        = bool
  default     = true
}

variable "read_replica_deletion_protection" {
  description = "Used to block Terraform from deleting replica SQL Instances."
  type        = bool
  default     = false
}

variable "enable_default_db" {
  description = "Enable or disable the creation of the default database"
  type        = bool
  default     = true
}

variable "enable_default_user" {
  description = "Enable or disable the creation of the default user"
  type        = bool
  default     = true
}



/**************************************

Variables Labeling Topic & Subscription

**************************************/

variable "aexp_app_env" {
    type = string
    description = "This is used for determining the environment type"
    default = "eng"
    validation {
      condition     = contains(["eng", "dev", "test", "prod"], var.aexp_app_env)
      error_message = "Valid values for var: aexp_app_env are (eng,dev,test,prod)."   
    }
}

variable "aexp_data_classification" {
    type = string
    description = "This is used for determining the classifiction of data"
    default = "internal"
    validation {
      condition     = contains(["internal", "public", "restricted", "secret"], var.aexp_data_classification)
      error_message = "Valid values for var: aexp_data_classification) are (internal,public,restricted,secret)."   
    }
}

variable "aexp_data_sensitivity" {
    type = string
    description = "The usage of this label corresponds to the Sensitive Data Elements section within the TECH02.01 Information Ownership and Classification Standard."
    default = "none"
    validation {
      condition     = contains(["p1", "p2", "p3", "none"], var.aexp_data_sensitivity)
      error_message = "Valid values for var: aexp_data_sensitivity are (p1,p2,p3,none)."   
    }
}

variable "aexp_app_carid" {
    type = string
    description = "The CAR ID of the resource owner, or intended user of the resource. Always 8 to 9 numeric digits in length, no leading 0s, and omit the typical AIM prefix."
    default = "200004806"
}


variable "aexp_app_name" {
    type = string
    description = "Either the application name as defined within CAR, or if applicable the distinct service or subcomponent name if using a microservices architecture."
    default = "sample-name"
}
 

variable "aexp_app_tier" {
    type = string
    description = "Enables automation to stop/start resources."
    default = "5"
    validation {
      condition     = contains(["0", "1", "2", "3", "4", "5"], var.aexp_app_tier)
      error_message = "Valid values for var: aexp_app_tier are (0,1,2,3,4,5)."   
    }
}


variable "aexp_ops_supportgroup" {
    type = string
    description = "The Service Now support workgroup associated with the operations of the resource."
    default = "sample_supportgroup"
}

variable "aexp_app_supportgroup" {
    type = string
    description = "The ServiceNow workgroup which supports the resource at the application level"
    default = "sample_supportgroup"
}

variable "aexp_lifecycle_changenumber" {
    type = string
    description = "RFC Number / Change Number.This will be tagged to resources which are part of the associated change."
    default = "CHG000000000"
    validation {
      condition     = substr(var.aexp_lifecycle_changenumber , 0, 3) == "CHG" || substr(var.aexp_lifecycle_changenumber , 0, 4) == "EMER"
      error_message = "Valid values for aexp_lifecycle_changenumber  must start with CHG or EMER."   
              }
}
 
variable "aexp_net_designation" {
    type = string
    description = "This must correspond with the Designation table for environments created after January 1st, 2021 as described in the Network Data Security Procedure."
    default = ""
    validation {
      condition     = contains(["application","backup","critical-infrastructure","database","enterprise","internet","internet-outbound","management","orchestration","scrubbing","security","storage","support"], var.aexp_net_designation)
      error_message = "Valid value are application,backup,critical-infrastructure,database,enterprise,internet,internet-outbound,management,orchestration,scrubbing,security,storage,support."   
              }
}

variable "aexp_account_type" {
    type = string
    description = "This is used for determining the roles created in the account."
    default = "platform"
    validation {
        condition     = contains(["infrastructure", "security", "platform"], var.aexp_account_type)
        error_message = "Valid values for var: aexp_account_type are (infrastructure, security, platform)."   
    }
}

variable "aexp_provisioner_carid" {
  type = string
  description = "The CAR ID associated with the project or team that owns the tool which provisioned the resource. This could be the same as aexp-owner-carid,or a different CAR ID if provisioned on behalf of the aexp-owner-carid."
  default = "sample_car_id"

}

 
variable "aexp_provisioner_repo" {
  type = string
  description = "This is a required tag and must be the URI to the repository which contains the automation code."
  default = "sample_repo"
}

variable "aexp_provisioner_workspace" {
  type = string
  description = "This is a required tag and must be the name of the provisioning system segment, scope, or context, e.g. the name of the Terraform Enterprise Workspace."
  default = "sample_workspace"
}