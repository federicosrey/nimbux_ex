# Using Terraform to Create an Environment for Nimbux911

![version](https://img.shields.io/badge/version-1.0.0-blue.svg) 


* [Overview](#Overview)
* [Architecture for this solution](#Architecture-for-this-solution)
* [Configuration Variables for Terraform](#Configuration-variables-for-Terraform)
* [Run Script](#Run-Script)


## Overview

I have used terraform to create a virtual cluster on [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) machines. The terraform job expects variables set as environment variables or in a `aws.tfvars` file.

**NOTE** [Terraform](https://www.terraform.io/) must be version 1.1.1 or greater.

## Architecture for this solution

<img src="https://i.ibb.co/ZgrNSvf/solution.png">

## Configuration Variables for Terraform

| Environment Variable Name | tfvars name | Type | Default | Description |
| ------------------------- | ----------- | ---- | ------- | ----------- |
| region  | region | string | us-west-1 | Regional zone where resources will be provisioned |
| ami | ami | string | ami-009726b835c24a3aa | Image to be deployed |
| instance_type | instance_type | string | t2.micro | Choose the appropriate mix of resources for EC2 Instances |
| load_balancer_type | load_balancer_type | string | application | Choose load balancer type |
| vpc_name | vpc_name | string | "" | Choose VPC name | 
| vpc_cidr | vpc_cidr | string | "" | Cidr for VPC |
| private_subnet_name | private_subnet_name | string | "" | Choose name for private subnet |
| private_subnet_servers_cidr | private_subnet_servers_cidr | string | "" | Cidr for private subnet |
