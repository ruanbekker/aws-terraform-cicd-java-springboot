resource "aws_ecs_cluster" "prod" {
  name = "${var.environment_name}-${var.ecs_cluster_name}"
}