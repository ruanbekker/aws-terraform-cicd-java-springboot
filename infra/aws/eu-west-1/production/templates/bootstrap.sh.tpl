#!/bin/bash

# write ecs config
echo "ECS_CLUSTER=${ecs_cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_AVAILABLE_LOGGING_DRIVERS=[\"json-file\",\"awslogs\"]" >> /etc/ecs/ecs.config
echo "ECS_INSTANCE_ATTRIBUTES={\"environment\":\"${environment_name}\"}" >> /etc/ecs/ecs.config