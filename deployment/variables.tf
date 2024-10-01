variable "mongodb_org_id" {
    default = "6697c1ab7f91044c27ceff06"
}
variable "aws_account_id" {
    default = "676206932076"
}
variable "aws_vpc_id" {
    default = "vpc-06561d0e9379c384c" 
}
variable "aws_region" {
    default = "us-east-2"
}

variable "name" {
 type        = string
}

variable "teams" {
 type = list(object({
   team_id    = string
   role_names = list(string)
 }))
 default = []
}

variable "is_collect_database_specifics_statistics_enabled" {
 type        = bool
 default     = true
}

variable "is_data_explorer_enabled" {
 type        = bool
 default     = false
}

variable "is_extended_storage_sizes_enabled" {
 type        = bool
 default     = true
}

variable "is_performance_advisor_enabled" {
 type        = bool
 default     = true
}


variable "is_realtime_performance_panel_enabled" {
 type        = bool
 default     = true
}


variable "is_schema_advisor_enabled" {
 type        = bool
 default     = true
}


variable "with_default_alerts_settings" {
 type        = bool
 default     = true
}


variable "limits" {
 type = list(object({
   name  = string
   value = string
 }))
 default = []
}


variable "atlas_public_key" {
 type        = string
}


variable "atlas_private_key" {
 type        = string
}