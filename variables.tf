variable "region" {
default = "us-west-1"
}
variable "instance_type" {}
variable "creds" {}
variable "instance_key" {}
variable "vpc_cidr" {}
variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}
variable "private_subnet_apache_cidr" {}
variable "private_subnet_nginx_cidr" {}
variable "ami" {}