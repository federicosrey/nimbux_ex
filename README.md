# Using Terraform to Create an Environment for Nimbux911

![version](https://img.shields.io/badge/version-1.0.0-blue.svg) 


* [Overview](#Overview)
* [Architecture for this solution](#Architecture-for-this-solution)
* [Configuration Variables for Terraform](#Configuration-variables-for-Terraform)
* [Instalacion](#Instalacion)
* [End-Points](#End-Points)
* [Base de datos](#Base-de-datos)
* [Recursos](#Recursos)

## Overview

I have used terraform to create a virtual cluster on [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) machines. The terraform job expects variables set as environment variables or in a `aws.tfvars` file.

**NOTE** [Terraform](https://www.terraform.io/) must be version 1.1.1 or greater.

## Architecture for this solution

<img src="https://i.ibb.co/ZgrNSvf/solution.png">

## Configuration Variables for Terraform
