# terraform {
#    required_version = ">= 0.12"
#    required_providers {
#        mongodbatlas = {
#            source = "mongodb/mongodbatlas"
#            version = "1.14.0"
#        }
#    }
# }

# provider "mongodbatlas" {
#    public_key  = var.atlas_public_key
#    private_key = var.atlas_private_key
# }

# resource "mongodbatlas_database_user" "example_db_user" {
#   username           = "fabrizzio"
#   password           = "!Password123#"     # You can use sensitive values or secrets for production environments
#   project_id         = "6697c1ab7f91044c27ceff98"
#   auth_database_name = "admin"               # Admin database for user authentication
#   roles {
#     role_name     = "readWrite"              # Role for the user (e.g., readWrite, dbAdmin, clusterMonitor)
#     database_name = "exampleDatabase"        # Database the role applies to
#   }

#   scopes {
#     name = "Cluster0" # Assign this user to a specific cluster
#     type = "CLUSTER"
#   }
# }
