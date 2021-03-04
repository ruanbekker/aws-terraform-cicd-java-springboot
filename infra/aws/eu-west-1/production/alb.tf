resource "aws_security_group" "alb" {
  name        = "${var.environment_name}-${var.ecs_cluster_name}-alb-sg"
  description = "Allows Traffic from Internet to ALB SG"
  vpc_id      = data.aws_vpc.main.id 
  tags = {
    Name        = "${var.environment_name}-${var.ecs_cluster_name}-alb-sg"
  }
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.alb.id
  description       = "Allows Internet to Connect to TCP 443"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allows Internet to Connect to TCP 80"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id
  description       = "Allows Egress"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_alb" "ecs" {
  name                       = "ecs-${var.environment_name}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = random_shuffle.public_subnets.result
  enable_deletion_protection = false
  tags = {
    Name        = "ecs-${var.environment_name}-alb"
    Environment = var.environment_name
  }
}

resource "aws_alb_target_group" "service_tg" {
  name                 = "${var.environment_name}-${var.service_name_short}-ecs-tg"
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = data.aws_vpc.main.id
  target_type          = "instance"
  deregistration_delay = 10

  health_check {
    interval          = 15
    timeout           = 5
    healthy_threshold = 2
    path              = var.ecs_tg_healthcheck_endpoint
    matcher           = "200"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_alb.ecs ]
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.ecs.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.ecs.arn 
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.validate.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Page cannot be found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "forward_to_tg" {
  listener_arn = aws_alb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.service_tg.arn
  }

  condition {
    source_ip {
      values = [
        "0.0.0.0/0"
      ]
    }
  }

  condition {
    host_header {
      values = ["${var.route53_record_set}.${var.route53_hosted_zone}"]
    }
  }

}
