variable "access_key" {}
variable "secret_key" {}
variable "aws_region" {}
variable "project_vpc_cidr" {}
variable "project_subnets" {}
variable "project_name" {}
variable "project_environment" {}
variable "instance_type" {}
variable "instance_ami" {
  type = map(string)
}
locals {
  common_tags = {
    project     = var.project_name,
    environment = var.project_environment
  }
}
variable "frontend-webaccess-ports" {
  description = "port for frontend security groups"
  type        = set(string)
}
variable "domain_name" {
  default = "leanjoan.tech"
}
variable "db_root_password" {}
variable "db_extra_username" {}
variable "db_extra_password" {}
variable "db_extra_dbname" {}
variable "db_extra_host" {}
