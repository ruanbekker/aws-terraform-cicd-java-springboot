data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "ecs_container_instance_role" {
  name               = "${var.ecs_cluster_name}-${var.service_name}-${var.environment_name}-instance-role"
  path               = "/service-role/"
  assume_role_policy = file("templates/ecs_container_instance_iam_role_policy.json")
}

resource "aws_iam_policy_attachment" "ecs_instance_policy_attach" {
  name       = "ecs-instance-policy-attachment"
  roles      = [aws_iam_role.ecs_container_instance_role.name]
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn
}

resource "aws_iam_instance_profile" "ecs_container_instance_profile" {
  name  = "${var.ecs_cluster_name}-${var.service_name}-${var.environment_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_container_instance_role.name
}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.ecs_cluster_name}-${var.service_name}-${var.environment_name}-task-role"
  path               = "/service-role/"
  assume_role_policy = file("templates/ecs_tasks_iam_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.ecs_cluster_name}-${var.service_name}-${var.environment_name}-execution-role"
  path               = "/service-role/"
  assume_role_policy = file("templates/ecs_tasks_iam_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

data "template_file" "ecs_execution_role_policy" {
  template = file("templates/ecs_execution_iam_policy.json")

  vars = {
    aws_region              = var.aws_region
    aws_account_id          = data.aws_caller_identity.current.account_id
    service_name            = var.service_name
    environment_name        = var.environment_name
  }
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "${var.ecs_cluster_name}-${var.service_name}-${var.environment_name}-execution-policy"
  role   = aws_iam_role.ecs_execution_role.id
  policy = data.template_file.ecs_execution_role_policy.rendered
}