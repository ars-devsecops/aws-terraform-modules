################################################################################
# RDS Module — ars-devsecops
# Production-grade RDS with encryption, automated backups,
# Multi-AZ, and Secrets Manager integration
################################################################################

# ── Subnet Group ─────────────────────────────────────────────────────────────
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.name}-rds-subnet-group" })
}

# ── Security Group ────────────────────────────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "Security group for RDS — allow only app tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "DB port from app tier only"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = var.app_security_group_ids
  }

  tags = merge(var.tags, { Name = "${var.name}-rds-sg" })
}

# ── Secrets Manager — DB credentials ─────────────────────────────────────────
resource "aws_secretsmanager_secret" "rds" {
  name                    = "${var.name}/rds/credentials"
  description             = "RDS credentials for ${var.name}"
  recovery_window_in_days = 7

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.this.address
    port     = var.db_port
    dbname   = var.db_name
  })
}

# ── RDS Instance ──────────────────────────────────────────────────────────────
resource "aws_db_instance" "this" {
  identifier        = "${var.name}-rds"
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  backup_retention_period   = var.backup_retention_days
  backup_window             = "02:00-03:00"
  maintenance_window        = "sun:04:00-sun:05:00"
  auto_minor_version_upgrade = true

  deletion_protection      = var.deletion_protection
  skip_final_snapshot      = false
  final_snapshot_identifier = "${var.name}-final-snapshot"

  enabled_cloudwatch_logs_exports = var.cloudwatch_logs_exports
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn

  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  tags = merge(var.tags, { Name = "${var.name}-rds" })
}

# ── Enhanced Monitoring Role ──────────────────────────────────────────────────
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.name}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
