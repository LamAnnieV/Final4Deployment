# Target Group for InstanceA
resource "aws_lb_target_group" "target_group_instanceA" {
  name        = "F4target-instanceA"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.final4_vpc.id

  health_check {
    enabled = true
    path    = "/health"
  }
}

# Target Group for InstanceC
resource "aws_lb_target_group" "target_group_instanceC" {
  name        = "F4target-instanceC"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.final4_vpc.id

  health_check {
    enabled = true
    path    = "/health"
  }
}

# Application Load Balancer
resource "aws_alb" "ALB" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  subnets = [
    aws_subnet.publicA.id,
    aws_subnet.publicC.id
  ]

  security_groups = [aws_security_group.alb_sg.id]

  depends_on = [
    aws_internet_gateway.final4_igw,
    aws_lb_target_group.target_group_instanceA,
    aws_lb_target_group.target_group_instanceC
  ]
}

# Attach Target Groups to ALB
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_instanceA.arn
  }

}

# Output
output "alb_url" {
  value = "http://${aws_alb.ALB.dns_name}"
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.final4_vpc.id  # Replace with your VPC ID

  # Allow HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS (port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow custom port 3000
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow custom port 8000
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Default egress rule: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}
