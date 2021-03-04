resource "aws_cloudwatch_log_group" "ecs" {
  name = "${var.environment_name}-${var.ecs_cluster_name}-logs"
}

data "template_file" "service_task" {
  template = file("templates/taskdefinition.json")

  vars = {
    aws_region           = var.aws_region
    aws_account_id       = data.aws_caller_identity.current.account_id
    environment_name     = var.environment_name
    service_name         = var.service_name
    image                = aws_ecr_repository.repo.repository_url
    container_name       = "${var.environment_name}-${var.service_name}"
    container_port       = var.container_port
    host_port            = var.host_port
    reserved_task_memory = var.container_reserved_task_memory
    log_group            = aws_cloudwatch_log_group.ecs.name
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "${var.environment_name}-${var.service_name}"
  container_definitions    = data.template_file.service_task.rendered
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  placement_constraints {
    type = "memberOf"
    expression = "attribute:environment == ${var.environment_name}"
  }
}

data "aws_ecs_task_definition" "service_current" {
  task_definition = aws_ecs_task_definition.service.family
}

resource "aws_ecs_service" "service" {
  name            = "${var.environment_name}-${var.service_name}"
  task_definition = "${aws_ecs_task_definition.service.family}:${max(aws_ecs_task_definition.service.revision, data.aws_ecs_task_definition.service_current.revision)}"

  cluster         = aws_ecs_cluster.prod.id
  launch_type     = "EC2"
  desired_count   = var.container_desired_count

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.service_tg.arn
    container_name   = "${var.environment_name}-${var.service_name}"
    container_port   = var.container_port
  }
}
