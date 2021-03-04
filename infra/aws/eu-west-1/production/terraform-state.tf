terraform {
  backend "s3" {
    encrypt = true
    bucket = "your-terraform-remote-state"
    key = "aws-terraform-cicd-java-springboot/prod/ecs/terraform.tfstate"
    region = "eu-west-1"
    profile = "demo"
    shared_credentials_file = "~/.aws/credentials"
    dynamodb_table = "terraform-remote-state"
  }
}
