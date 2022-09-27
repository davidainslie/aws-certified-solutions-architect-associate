terraform {
  required_version = ">= 1.0.11"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.2.0"
    }

    local = {
      source = "hashicorp/local"
      version = "~> 2.2.3"
    }

    archive = {
      source = "hashicorp/archive"
      version = "~> 2.2.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17.1"
    }
  }
}

# North Virgina
provider "aws" {
  access_key = var.aws-access-key-id
  secret_key = var.aws-secret-access-key
  alias = "us-east-1"
  region = "us-east-1"
}

# Oregon
provider "aws" {
  access_key = var.aws-access-key-id
  secret_key = var.aws-secret-access-key
  alias = "us-west-2"
  region = "us-west-2"
}