resource "aws_s3_bucket" "codepipeline_artifact_store" {
  bucket        = "codepipeline-${var.environment_name}-artifacts-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.service_name}-${var.environment_name}-codepipeline-role"
  path               = "/service-role/"
  assume_role_policy = file("templates/codepipeline_iam_role_policy.json")
}

data "template_file" "codepipeline_policy" {
  template = file("templates/codepipeline_iam_policy.json")

  vars = {
    codepipeline_bucket_arn = aws_s3_bucket.codepipeline_artifact_store.arn
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.service_name}-${var.environment_name}-codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.template_file.codepipeline_policy.rendered
}

resource "aws_codepipeline" "pipeline" {
  name     = "${var.service_name}-${var.environment_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifact_store.bucket
    type     = "S3"
  }

  stage {
    name = var.codepipeline_source_stage_name

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:${var.aws_region}:${data.aws_caller_identity.current.account_id}:connection/${var.codestar_connection_id}"
        FullRepositoryId = "${var.github_username}/${var.github_repo_name}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = var.codepipeline_build_stage_name

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["imagedefinitions"]

      configuration = {
        ProjectName = "${var.service_name}-${var.environment_name}-build"
      }
    }
  }

  stage {
    name = var.codepipeline_deploy_stage_name

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration = {
        ClusterName = "${var.environment_name}-${var.ecs_cluster_name}"
        ServiceName = "${var.environment_name}-${var.service_name}"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

resource "aws_codepipeline_webhook" "webhook" {
  name            = "${var.service_name}-${var.environment_name}-webhook-github"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.pipeline.name

  authentication_configuration {
    secret_token = local.webhook_secret
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

resource "github_repository_webhook" "webhook" {
  repository = var.github_repo_name

  configuration {
    url          = aws_codepipeline_webhook.webhook.url
    content_type = "json"
    insecure_ssl = true
    secret       = local.webhook_secret
  }

  events = ["push"]
}