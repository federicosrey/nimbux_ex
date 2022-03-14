# Using Terraform to Create an Environment for Nimbux911

![version](https://img.shields.io/badge/version-1.0.0-blue.svg) 


* [Overview](#Overview)
* [Architecture for this solution](#Architecture-for-this-solution)
* [Configuration Variables for Terraform](#Configuration-variables-for-Terraform)
* [Run Script](#Run-Script)
* [Outputs](#Outputs)


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
| vpc_name | vpc_name | string | "" | Choose VPC name | 
| vpc_cidr | vpc_cidr | string | "" | Cidr for VPC |
| private_subnet_name | private_subnet_name | string | "" | Choose name for private subnet |
| private_subnet_servers_cidr | private_subnet_servers_cidr | string | "" | Cidr for private subnet |
| public_subnet_az1_name | public_subnet_az1_name | string | "" | Choose name for public subnet on AZ1 |
| public_subnet_az2_name | public_subnet_az2_name | string | "" | Choose name for public subnet on AZ2 |
| public_subnet_az1_cidr | public_subnet_az1_cidr | string | "" | Cidr for public subnet on AZ1 |
| public_subnet_az2_cidr | public_subnet_az2_cidr | string | "" | Cidr for public subnet on AZ2 |
| avz1 | avz1 | string | "" | Selectr Availability Zone for this region | 
| avz2 | avz2 | string | "" | Selectr Availability Zone for this region | 
| load_balancer_type | load_balancer_type | string | application | Choose load balancer type |
| load_balancer_name | load_balancer_name | string | "" | Load balancer name |
| tg_name | tg_name | string | "" | Target group name |
| natgtw_name | natgtw_name | string | "" | Nat Gateway name |
| ig_name | ig_name | string | "" | Internet Gateway name |
| key_name | key_name | string | "" | Keypair name |

## Run script

Run the following to ensure terraform will only perform the expected actions

`terraform apply -var-file=aws.tfvars`

## Outputs

**dns_load_balancer**

URL to the ALB on the web
