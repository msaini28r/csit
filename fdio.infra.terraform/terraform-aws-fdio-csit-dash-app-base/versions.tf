terraform {
  backend "consul" {
    address = "consul.service.consul:8500"
    scheme  = "http"
    path    = "terraform/app-base"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.3.0"
    }
    vault = {
      version = ">= 3.2.1"
    }
  }
  required_version = ">= 1.1.4"
}
