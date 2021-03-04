[
    {
      "name": "${container_name}",
      "image": "${image}",
      "memoryReservation": ${reserved_task_memory},
      "portMappings": [
        {
          "containerPort": ${container_port},
          "hostPort": ${host_port}
        }
      ],
      "environment": [
        {
          "name": "AWS_DEFAULT_REGION",
          "value": "eu-west-1"
        }
      ],
      "secrets": [
        {
          "name": "MYSQL_HOST",
          "valueFrom": "arn:aws:ssm:${aws_region}:${aws_account_id}:parameter/${service_name}/${environment_name}/MYSQL_HOST"
        },
        {
          "name": "MYSQL_PORT",
          "valueFrom": "arn:aws:ssm:${aws_region}:${aws_account_id}:parameter/${service_name}/${environment_name}/MYSQL_PORT"
        },
        {
          "name": "MYSQL_PASS",
          "valueFrom": "arn:aws:ssm:${aws_region}:${aws_account_id}:parameter/${service_name}/${environment_name}/MYSQL_PASS"
        },
        {
          "name": "MYSQL_DATABASE",
          "valueFrom": "arn:aws:ssm:${aws_region}:${aws_account_id}:parameter/${service_name}/${environment_name}/MYSQL_DATABASE"
        },
        {
          "name": "MYSQL_USER",
          "valueFrom": "arn:aws:ssm:${aws_region}:${aws_account_id}:parameter/${service_name}/${environment_name}/MYSQL_USER"
        }
      ],
      "networkMode": "bridge",
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${log_group}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "${service_name}"
        }
      }
    }
  ]
