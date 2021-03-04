terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
    }
    random = {
      version = "~> 3.0"
    }
    null = {
      version = "~> 3.0"
    }
    template = {
      version = "~> 2.1"
    }
    github = {
      source  = "integrations/github"
      version = ">= 4.5.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "demo"
  shared_credentials_file = "~/.aws/credentials"
}

provider "github" {
  token        = local.github_token
  organization = local.github_username
}

provider "template" {}
provider "random" {}
provider "null" {}