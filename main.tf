
module "pg" {

  source = "../modules"

  ######################
  # Common            #
  #####################

  name                 = var.pg_ha_name
  random_instance_name = var.random_instance_name
  project_id           = var.project_id
  database_version     = var.database_version
  region               = var.region

  #########################
  # Master configurations #
  #########################

  tier                            = var.tier
  zone                            = var.zone
  availability_type               = var.availability_type
  maintenance_window_day          = var.maintenance_window_day
  maintenance_window_hour         = var.maintenance_window_hour
  maintenance_window_update_track = var.maintenance_window_update_track

  deletion_protection = var.deletion_protection

  database_flags = var.database_flags

  user_labels = var.user_labels

  ip_configuration     = var.ip_configuration
  backup_configuration = var.backup_configuration


  ###############################
  # Read replica configurations #
  ###############################

  read_replica_name_suffix = "-demo"
  read_replicas            = var.read_replicas

  db_name      = var.pg_ha_name
  db_charset   = var.db_charset
  db_collation = var.db_collation

  additional_databases = var.additional_databases

  user_name     = var.user_name
  user_password = var.user_password

  additional_users = var.additional_users

}