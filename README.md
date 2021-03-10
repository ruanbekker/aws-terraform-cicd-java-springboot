# aws-terraform-cicd-java-springboot
Terraform: AWS CICD with CodePipeline, CodeBuild, ECS and a Springboot App

The [all-in-one](https://github.com/ruanbekker/aws-terraform-cicd-java-springboot/tree/all-in-one) branch has the application code, application infrastructure and pipeline infrastructure in one repository.

## Description

This is a demo on how to use Terraform to deploy your AWS Infrastructure for your Java Springboot application to run as a container on ECS.

You will be able to boot your application locally using docker-compose as well as building the following infrastructure on AWS for this application:

- ALB, Target Groups, 80 and 443 Target Group Listeners, with Listener Configurations
- ACM Certificates, ACM Certificate Validation and Route53 Configuration
- CI/CD Pipeline with CodePipeline, CodeBuild and Deployment to ECS with EC2 as target
- Github Webhook (Pipeline will trigger on the main branch but configurable in `variables.tf`)
- ECR Repository
- ECS Container Instance with Userdata
- ECS Cluster, ECS Service and ECS Task Definition with variables
- S3 Buckets for CodePipeline and CodeBuild Cache
- RDS MySQL Instance
- SSM Parameters for RDS Password, Hostname etc, which we will place into the Task Definition as well
- IAM Roles, Policies and Security Groups

When I tested, terraform took `4m 24s` to deploy the infrastructure and when I made a commit to the `main` branch the pipeline took about 5 minutes to deploy.

## Deploy Local

Boot our application with docker-compose:

```
$ docker-compose up --build
```

## Test the Application Locally

Make a request to view all cars:

```
$ curl http://localhost:8080/api/cars
[]
```

Create one car:

```
$ curl -H "Content-Type: application/json" http://localhost:8080/api/cars -d '{"make":"bmw", "model": "m3"}'
{"id":3,"make":"bmw","model":"m3","createdAt":"2021-03-01T14:12:07.624+00:00","updatedAt":"2021-03-01T14:12:07.624+00:00"}
```

View all cars again:

```
$ curl http://localhost:8080/api/cars
[{"id":3,"make":"bmw","model":"m3","createdAt":"2021-03-01T14:12:08.000+00:00","updatedAt":"2021-03-01T14:12:08.000+00:00"}]
```

View a specific car:

```
$ curl http://localhost:8080/api/cars/3
{"id":3,"make":"bmw","model":"m3","createdAt":"2021-03-01T14:12:08.000+00:00","updatedAt":"2021-03-01T14:12:08.000+00:00"}
```

Delete a car:

```
$ curl -XDELETE http://localhost:8080/api/cars/3
```

View application status:

```
$ curl -s http://localhost:8080/status | jq .
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "MySQL",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 62725623808,
        "free": 2183278592,
        "threshold": 10485760,
        "exists": true
      }
    },
    "ping": {
      "status": "UP"
    }
  }
}
```

Or the database status individually:

```
$ curl -s http://localhost:8080/status/db
{"status":"UP","details":{"database":"MySQL","validationQuery":"isValid()"}}
```

## Installing Terraform

For Mac:

```
$ wget https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_darwin_amd64.zip
$ unzip terraform_0.14.7_darwin_amd64.zip
$ mv ./terraform /usr/local/bin/terraform
$ rm -rf terraform_0.14.7_darwin_amd64.zip
```

View the version:

```
$ terraform -version
Terraform v0.14.7
```

## Assumptions for AWS

For AWS, I have the current existing resources, which I will reference in terraform with the `data` source:

### vpc
- vpc with the name "main", which is my non default-vpc

### subnets
- 3 public subnets with tags Tier:public
- 3 private subnets with tags Tier:private

### nat gateway
- nat gw with eip for private range and added to my private routing table 0.0.0.0/0 to natgw

### rds
- subnet group with the name "private" which is linked to my private subnets

### route53
- existing hosted zone

### codestar connections 
- codestar connection linked to my github account:
- https://eu-west-1.console.aws.amazon.com/codesuite/settings/connections
- the connection id is defined in: var.codestar_connection_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

## Required Environment Variables

Github Personal Access Token:

Head over to https://github.com/settings/tokens/new and create a token with the following scopes:
- `admin:repo_hook`

Set the environment variable as:

```
$ export TF_VAR_github_token=${your-github-pat}
```

which will be referenced in `infra/aws/eu-west-1/production/locals.tf`:

```
# locals.tf
locals {
  github_token = var.github_token
}
```

Other variables that needs replacement resides in `infra/aws/eu-west-1/production/variables.tf`:

```
variable "aws_region" {}
variable "codebuild_docker_image" {}
variable "codebuild_security_group_name" {}
variable "codepipeline_build_stage_name" {}
variable "codepipeline_deploy_stage_name" {}
variable "codepipeline_source_stage_name" {}
variable "codestar_connection_id" {}
variable "container_desired_count" {}
variable "container_port" {}
variable "container_reserved_task_memory" {}
variable "ecs_cluster_name" {}
variable "ecs_container_instance_type" {}
variable "ecs_tg_healthcheck_endpoint" {}
variable "environment_name" {}
variable "github_branch" {}
variable "github_repo_name" {}
variable "github_token" {}
variable "github_username" {}
variable "host_port" {}
variable "platform_type" {}
variable "rds_admin_username" {}
variable "rds_instance_type" {}
variable "rds_subnet_group_name" {}
variable "route53_hosted_zone" {}
variable "route53_record_set" {}
variable "service_hostname" {}
variable "service_name" {}
variable "service_name_short" {}
variable "ssh_keypair_name" {}
variable "vpc_name" {}
```

Also ensure your configuration matches your setup in:
- `infra/aws/eu-west-1/production/providers.tf`
- `infra/aws/eu-west-1/production/terraform-state.tf`

## Notes

I am using the admin credentials for the application to use to authenticate against rds (for this demo), but you can use something like ansible and the local-exec provisioner to provision a rds username and password like [here](https://github.com/ruanbekker/terraformfiles/blob/master/aws-cicd-ecs-codepipeline/existing-vpc-ecs-rds-new-dbuser-ansible-ssm/infra/rds.tf#L11-L40).

I am also using `String` as the type for SSM, if you save secret information, you should be using `SecureString` and encrypt it with KMS, but for the demo I won't be doing that.


## Deploy Infrastructure to AWS

Validate:

```
$ terraform validate
Success! The configuration is valid.
```

Variables isn't supported for backend, see [this issue](https://github.com/hashicorp/terraform/issues/13022#issuecomment-294262392), to use variables, you can [look at this example](https://github.com/ruanbekker/terraformfiles/tree/master/s3-backend-with-variables):

Initialize:

```
$ terraform init -input=false
```

Plan:

```
$ terraform plan
...
  # aws_acm_certificate.cert will be created
  # aws_acm_certificate_validation.validate will be created
  # aws_alb.ecs will be created
  # aws_alb_listener.http will be created
  # aws_alb_listener.https will be created
  # aws_alb_target_group.service_tg will be created
  # aws_cloudwatch_log_group.ecs will be created
  # aws_codebuild_project.build will be created
  # aws_codepipeline.pipeline will be created
  # aws_codepipeline_webhook.webhook will be created
  # aws_codestarconnections_connection.github will be created
  # aws_db_instance.prod will be created
  # aws_ecr_repository.repo will be created
  # aws_ecs_cluster.prod will be created
  # aws_ecs_service.service will be created
  # aws_ecs_task_definition.service will be created
  # aws_iam_instance_profile.ecs_instance will be created
  # aws_iam_role.codebuild_role will be created
  # aws_iam_role.codepipeline_role will be created
  # aws_iam_role.ecs_instance_role will be created
  # aws_iam_role.ecs_task_role will be created
  # aws_iam_role_policy.codebuild_policy will be created
  # aws_iam_role_policy.codepipeline_policy will be created
  # aws_iam_role_policy.ecs_instance_policy will be created
  # aws_iam_role_policy.ecs_task_policy will be created
  # aws_instance.ec2 will be created
  # aws_lb_listener_rule.forward_to_tg will be created
  # aws_route53_record.record["rbkr.xyz"] will be created
  # aws_route53_record.www will be created
  # aws_s3_bucket.codepipeline_artifact_store will be created
  # aws_security_group.alb will be created
  # aws_security_group.codebuild will be created
  # aws_security_group.ecs_instance will be created
  # aws_security_group.rds_instance will be created
  # aws_security_group_rule.alb_egress will be created
  # aws_security_group_rule.container_port will be created
  # aws_security_group_rule.ec2_egress will be created
  # aws_security_group_rule.http will be created
  # aws_security_group_rule.https will be created
  # aws_security_group_rule.mysql will be created
  # aws_security_group_rule.ssh will be created
  # aws_ssm_parameter.database_host will be created
  # aws_ssm_parameter.database_name will be created
  # aws_ssm_parameter.database_password will be created
  # aws_ssm_parameter.database_port will be created
  # aws_ssm_parameter.database_user will be created
  # github_repository_webhook.webhook will be created
  # random_password.db_admin_password will be created
  # random_shuffle.subnets will be created
  # random_string.secret will be created
Plan: 50 to add, 0 to change, 0 to destroy.
```

Apply:

```
$ terraform apply -input=false -auto-approve
Apply complete! Resources: 55 added, 0 changed, 0 destroyed.
Releasing state lock. This may take a few moments...

Outputs:

account_id = "xxxxxxxxxxxx"
alb_dns = "ecs-prod-alb-xxxxxxxxxx.eu-west-1.elb.amazonaws.com"
caller_arn = "arn:aws:iam::xxxxxxxxxxxx:user/x"
caller_user = "AXXXXXXXXXXXXXXXXXXXXXX"
db_address = "ecs-prod-rds-instance.xxxxxxxxxxxx.eu-west-1.rds.amazonaws.com"
environment_name = "prod"
service_hostname = "www.rbkr.xyz"

~/aws-terraform-cicd-java-springboot/infra/aws/eu-west-1/production main* 4m 24s
```

Now that your infrastructure is built, we can trigger our repo to start the pipeline:

```
$ git commit --allow-empty --message "trigger pipeline"
$ git push origin main
```

## A Tour through our Infra

We can see our Pipeline when you navigate to CodePipeline:

![](docs/screenshots/codepipeline-overview.png)

When you select the pipeline to see our stages:

![](docs/screenshots/codepipeline-detail-view.png)

We can view our ECS Cluster:

![](docs/screenshots/ecs-cluster-view.png)

Our task:

![](docs/screenshots/ecs-task-view.png)

And also check that our ACM Certificates was validated (but terraform did that already):

![](docs/screenshots/acm-certificates.png)

## Test the Application on AWS

Make a request to view all the cars:

```
❯ curl -i https://www.rbkr.xyz/api/cars                                                                        
HTTP/2 200 
date: Wed, 03 Mar 2021 15:29:41 GMT
content-type: application/json

[]
```

Create a car:

```
❯ curl -i -H "Content-Type: application/json" -XPOST https://www.rbkr.xyz/api/cars -d '{"make": "bmw", "model": "m3"}'
HTTP/2 200 
date: Wed, 03 Mar 2021 15:29:33 GMT
content-type: application/json

{"id":1,"make":"bmw","model":"m3","createdAt":"2021-03-03T15:29:33.707+00:00","updatedAt":"2021-03-03T15:29:33.707+00:00"}
```

View all the cars:

```
❯ curl -i https://www.rbkr.xyz/api/cars                                                                        
HTTP/2 200 
date: Wed, 03 Mar 2021 15:29:41 GMT
content-type: application/json

[{"id":1,"make":"bmw","model":"m3","createdAt":"2021-03-03T15:29:34.000+00:00","updatedAt":"2021-03-03T15:29:34.000+00:00"}]
```

View the application status:

```
❯ curl -s https://www.rbkr.xyz/status | jq .
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "MySQL",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 10501771264,
        "free": 9604685824,
        "threshold": 10485760,
        "exists": true
      }
    },
    "ping": {
      "status": "UP"
    }
  }
}
```

## Destroy Infrastructure on AWS:

Destroy:

```
$ terraform destroy -auto-approve
Destroy complete! Resources: 55 destroyed.
Releasing state lock. This may take a few moments...
```

## Destroy Application running Locally:

```
$ docker-compose down
```

## Resources 

### AWS Resources

- [Difference between Task Role and Execution Role](https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_TaskDefinition.html)

### Terraform Resources

- [Shunit Tests for User Data](https://alexharv074.github.io/2020/01/31/unit-testing-a-terraform-user_data-script-with-shunit2.html)

### Java Resources
- [spring-testing-separate-data-source](https://www.baeldung.com/spring-testing-separate-data-source) and [github](https://github.com/eugenp/tutorials/tree/master/persistence-modules/spring-boot-persistence)
- [testing-with-configuration-classes-and-profiles](https://spring.io/blog/2011/06/21/spring-3-1-m2-testing-with-configuration-classes-and-profiles)
- [hibernate-ddl-auto-example](https://www.onlinetutorialspoint.com/hibernate/hbm2ddl-auto-example-hibernate-xml-config.html)
- [cleaning-up-spring-boot-integration-tests-logs](https://ricardolsmendes.medium.com/cleaning-up-spring-boot-integration-tests-logs-5b2d0a5f29bc)
- [docker-caching-strategies](https://testdriven.io/blog/faster-ci-builds-with-docker-cache/)

## Credit

Huge thanks to [Cobus Bernard](https://github.com/cobusbernard/aws-containers-for-beginners) for his webinar back in 2019, and for sharing his terraform source code, as I learned a LOT from him, and this example is based off his terraform structure.

Also great thanks to [callicoder](https://www.callicoder.com/spring-boot-rest-api-tutorial-with-mysql-jpa-hibernate/) for the rest api example which this example is based off.
