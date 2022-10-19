resource "aws_ecs_cluster" "main" {
  name = "timi-cluster"
}

resource "aws_cloudwatch_log_group" "log" {
  name = "timmie-service"
}

resource "aws_ecs_task_definition" "timitech" {
  family                   = "timitech-app"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  container_definitions = jsonencode([
    {
      name      = "timmietech"
      image     = "INSERT-YOUR-ECR-URL-HERE"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log.name
          "awslogs-region"        = "eu-west-2"
          "awslogs-stream-prefix" = "timmietech"
        }
      }

    }
  ])
}



resource "aws_ecs_service" "test-service" {
  name            = "timmietech"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.timitech.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.timitech.id
    container_name   = "timmietech"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.timitech]
}



