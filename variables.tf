variable "region" {
    default = "us-west-1"
}
variable "instance_type" {
    default = "t2.micro"
}
variable "ami" {
    default = "ami-009726b835c24a3aa"
}
variable "load_balancer_type" {
    default = "application"
}
variable "vpc_cidr" {}
variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}
variable "private_subnet_apache_cidr" {}
variable "private_subnet_nginx_cidr" {}
variable "tg_name" {}
variable "vpc_name" {}
variable "ig_name" {}
variable "load_balancer_name" {}
variable "key_name" {}
