################################################################################
# ALB Module — ars-devsecops
# Application Load Balancer with Blue/Green target group support,
# HTTPS listener, access logs, and WAF-ready configuration
################################################################################

# ── Security Group ────────────────────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-alb-sg" })
}

# ── ALB ───────────────────────────────────────────────────────────────────────
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = true

  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = "${var.name}-alb"
    enabled = var.access_logs_bucket != "" ? true : false
  }

  tags = merge(var.tags, { Name = "${var.name}-alb" })
}

# ── Blue Target Group (Production) ───────────────────────────────────────────
resource "aws_lb_target_group" "blue" {
  name        = "${var.name}-blue-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200-299"
  }

  tags = merge(var.tags, { Name = "${var.name}-blue-tg", Env = "blue" })

  lifecycle { create_before_destroy = true }
}

# ── Green Target Group (Staging / New Release) ────────────────────────────────
resource "aws_lb_target_group" "green" {
  name        = "${var.name}-green-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200-299"
  }

  tags = merge(var.tags, { Name = "${var.name}-green-tg", Env = "green" })

  lifecycle { create_before_destroy = true }
}

# ── HTTPS Listener (Production → Blue) ───────────────────────────────────────
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }

  tags = var.tags
}

# ── HTTP → HTTPS Redirect ─────────────────────────────────────────────────────
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = var.tags
}

# ── Test Listener (Green — port 8443) ────────────────────────────────────────
resource "aws_lb_listener" "test" {
  count             = var.enable_test_listener ? 1 : 0
  load_balancer_arn = aws_lb.this.arn
  port              = 8443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }

  tags = var.tags
}
