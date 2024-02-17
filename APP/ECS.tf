data "aws_iam_role" "labrole" {
  name = "LabRole"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "aws-cloud-sudeep-s3"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "rds" {
  backend = "s3"
  config = {
    bucket = "aws-cloud-sudeep-s3"
    key    = "rds/terraform.tfstate"
    region = "us-east-1"
  }
}


resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}


resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "my-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.labrole.arn
  task_role_arn            = data.aws_iam_role.labrole.arn

  container_definitions = jsonencode([
    {
      name          = "my-app"
      image         = "494992235231.dkr.ecr.us-east-1.amazonaws.com/app-image-docker-assignment:v0.1"
      essential = true
      cpu           = 256
      memory        = 512
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DBHOST", value = data.terraform_remote_state.rds.outputs.DBHOST },
        { name = "DBPORT", value = "3306" },
        { name = "DBUSER", value =  "dbadmin" },
        { name = "DBPWD", value =  "sudeepsaurabh01"},
        { name = "DATABASE", value = "employee" },
        { name = "APP_COLOR", value = "blue" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.cloudwatch_logs.name
          awslogs-stream-prefix = "/aws/ecs"
          awslogs-region        = "us-east-1"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  scheduling_strategy                = "REPLICA"


  network_configuration {
    subnets         =  data.terraform_remote_state.network.outputs.webservers_subnet_id
    assign_public_ip = true
    security_groups = [data.terraform_remote_state.network.outputs.ecs_task_sg_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_tg.arn
    container_name   = "my-app"
    container_port   = 8080
  }
  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }


}

resource "aws_security_group_rule" "ecs_egress_to_rds" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id  = data.terraform_remote_state.network.outputs.ecs_task_sg_id
  source_security_group_id     = data.terraform_remote_state.network.outputs.rds_sg_id
}

resource "aws_security_group_rule" "ecs_ingress_from_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.network.outputs.ecs_task_sg_id
  source_security_group_id = data.terraform_remote_state.network.outputs.alb_sg_id
}