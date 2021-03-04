output "environment_name" {
  value = var.environment_name
}

output "alb_dns" {
  value = aws_alb.ecs.dns_name
}

output "service_hostname" {
  value = "${var.route53_record_set}.${var.route53_hosted_zone}"
}

output "db_address" {
  value = aws_db_instance.prod.address
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}
