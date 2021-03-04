variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "environment_name" {
  type    = string
  default = "prod"
}

variable "service_name" {
  type    = string
  default = "cargarage-api"
}

variable "service_name_short" {
  type    = string
  default = "cargarage"
}

variable "ecs_container_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "codebuild_security_group_name" {
  type    = string
  default = "vpc-codebuild" 
}

variable "container_port" {
  type    = string
  default = "8080"
}

variable "host_port" {
  type    = string
  default = "0"
}

variable "container_desired_count" {
  type    = string
  default = "1"
}

variable "container_reserved_task_memory" {
  type    = string
  default = "128"
}

variable "ecs_cluster_name" {
  type    = string
  default = "ecs-cluster"
}

variable "ecs_tg_healthcheck_endpoint" {
  type    = string
  default = "/status"
}

variable "github_username" {
  type    = string
  default = "ruanbekker"
}

variable "github_repo_name" {
  type    = string
  default = "aws-terraform-cicd-java-springboot"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "github_token" {
  type    = string
}

variable "route53_hosted_zone" {
  type    = string
  default = "example.com" 
}

variable "route53_record_set" {
  type    = string
  default = "www" 
}

variable "service_hostname" {
  type    = string
  default = "www.example.com"
}

variable "codestar_connection_id" {
  type    = string
  default = ""
}

variable "codebuild_docker_image" {
  type    = string 
  default = "aws/codebuild/standard:5.0"
}

variable "codepipeline_source_stage_name" {
  type    = string 
  default = "Source"
}

variable "codepipeline_build_stage_name" {
  type    = string 
  default = "Build"
}

variable "codepipeline_deploy_stage_name" {
  type    = string 
  default = "Prod"
}

variable "rds_admin_username" {
  type    = string
  default = "admin"
}

variable "rds_subnet_group_name" {
  type    = string
  default = "private"
}

variable "rds_instance_type" {
  type    = string
  default = "db.t2.micro" 
}

variable "platform_type" {
  type       = string
  default = "ecs" 
}

variable "ssh_keypair_name" {
  type    = string
  default = ""
}

variable "vpc_name" {
  type    = string
  default = "main"
}