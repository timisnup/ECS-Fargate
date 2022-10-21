#ALB Security group
resource "aws_security_group" "lb" {
  name        = "example-alb-security-group"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol    = "tcp"
    from_port   = var.http_port
    to_port     = var.http_port
    cidr_blocks = [var.open_cidr]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = var.protocol
    cidr_blocks = [var.open_cidr]
  }

  tags = {
    Namw = "allow_tls"
  }
}


#This security froup for ecs - Traffic to the ecs cluster sgould come from the ALB
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-task-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.default.id

  ingress {
    protocol        = "tcp"
    from_port       = var.http_port
    to_port         = var.http_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = var.protocol
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.open_cidr]
  }
}