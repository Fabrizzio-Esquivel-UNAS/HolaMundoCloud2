terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.21.1"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

resource "mongodbatlas_project" "my_project" {
  name   = "HolaMundoCloud"
  org_id = var.atlas_org_id
}

resource "mongodbatlas_database_user" "my_user" {
  project_id    = mongodbatlas_project.my_project.id
  auth_database_name = "admin"
  username      = "admin"
  password      = var.atlas_db_password
  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
}

resource "mongodbatlas_cluster" "cluster-test" {
  project_id              = mongodbatlas_project.my_project.id
  name                    = "cluster-holamundocloud"

  # Provider Settings "block"
  provider_name = "TENANT"
  backing_provider_name = "AWS"
  provider_region_name = "US_EAST_1"
  provider_instance_size_name = "M0"
}