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
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = jsonencode([
    {
      name      = "timmietech"
      image     = "204708917400.dkr.ecr.eu-west-2.amazonaws.com/timmietech:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.http_port
          hostPort      = var.http_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.log.name
          "awslogs-region"        = var.region
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
    container_port   = var.http_port
  }

  depends_on = [aws_lb_listener.timitech]
}



